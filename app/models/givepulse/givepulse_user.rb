class GivepulseUser < GivepulseBase
  include ActiveModel::Model

  # Attributes for the User
  attr_accessor :id, :created, :modified, :email, :phone, :first_name, :last_name,
                :middle_name, :preferred_name, :birthday, :ethnicity, :is_hispanic_latino,
                :gender, :minor, :tshirtsize, :city, :state, :student_id, :num_groups,
                :total_impacts, :total_hours, :total_verified_impacts, :total_verified_hours,
                :roles, :network_impacts, :network_hours, :network_verified_impacts,
                :network_verified_hours, :last_impact_date, :image, :cover_image,
                :causes, :skills, :research_areas, :education, :tags,
                :administrative_fields, :administrative_fields_detailed

  # Simulate ActiveRecord's where method
  # Example: GivepulseUser.where(group_id: 1479596), GivepulseUser.find_by(user_id: 9790174)
  def self.where(attributes)
    begin
      results = fetch_all_records('/users', attributes)
      results.map { |attrs| new(attrs.slice(*permitted_attrs)) }
    rescue StandardError => e
      Rails.logger.error("Error fetching users: #{e.message}")
      []
    end
  end

  # params => {:user=>{:administrative_fields=>{"81445"=>"No"}}} 
  # example: GivepulseUser.where(user_id: 4228632).first.update_user({user: {administrative_fields: {"81773" => "Yes" }}})
  def update_user(params)
    return false unless id
      
    begin
        response =  GivepulseUser.request_api("/users/#{id}", params, method: :put)
        # Rails.logger.debug("Original Response received: #{response}")
        response = JSON.parse(response.body)
        # Rails.logger.debug("Json Response received: #{response}")

        if response['updated']==1
          params.each do |key, value|
            if respond_to?("#{key}=") # Ensure the attribute exists
              send("#{key}=", value)
            end
          end
          Rails.logger.info("Successfully update the user with ID: #{id}")
          true
        else
          Rails.logger.warn("Failed to update user with ID #{id}: #{response}")
          false
        end
    rescue StandardError => e
        Rails.logger.error("Error updating user: #{e.message}")
        false
    end
  end
  

  # Adds/updates a single student as a GivePulse user in the given group.
  #
  # This is the single source of truth for "student -> GivePulse user" logic,
  # reused by both course roster imports (GivepulseCourse#add_students) and
  # bulk enrollment imports (see rake task givepulse:import_enrolled_students).
  #
  # @param student [Student, StudentRecord] must respond to :email, :firstname,
  #   :lastname, :dir_release, :major_branch_list, :sdb, :student_no (optional).
  #   Accepts either a Student (where #sdb returns the associated StudentRecord)
  #   or a StudentRecord directly (where #sdb returns self / no-ops) — see
  #   sdb_student resolution below.
  # @param group_id [Integer] GivePulse group to add the user to
  # @param existing_emails [Set<String>, nil] lowercase emails already in the
  #   group/GivePulse. When provided:
  #     - used to decide is_private (only new users are marked private)
  #     - mutated in place to include the newly added email (so callers can
  #       reuse the same Set across a loop without re-fetching with API call)
  # @param course_section [String, nil] optional cross-list section label
  #   (only relevant for course roster imports)
  # @param dry_run [Boolean] when true, builds the full request payload and
  #   logs what WOULD happen, but never calls the GivePulse API and never
  #   mutates existing_emails. Use this to safely test a run against
  #   thousands of students before committing.
  #
  # @return [Hash] { status: :added | :would_add | :skipped | :would_skip | :error,
  #                   email:, user_id: (optional), reason: (optional) }
  #
  # Example:
  #   GivepulseUser.add_student(student, group_id: 920703)
  #   GivepulseUser.add_student(student, group_id: 920703, dry_run: true)
  UW_EMAIL_DOMAINS = %w[uw.edu u.washington.edu washington.edu].freeze

  def self.add_student(student, group_id:, existing_emails: nil, course_section: nil, dry_run: false)
    if student.nil? || student.email.blank?
      student_no = student.respond_to?(:student_no) ? student.student_no : nil
      Rails.logger.warn("Skipping student (student_no: #{student_no}) — no email on file.")
      return { status: :skipped, email: nil, reason: 'missing_email' }
    end

    email  = student.email.strip.downcase
    domain = email.split('@', 2).last

    # Guard rail: this method (and the /users API call it makes) is only ever
    # meant to touch UW students. GivePulse accounts can have multiple emails
    # on file (e.g. a verified uw.edu + an unverified personal gmail), but
    # querying a user always surfaces the uw.edu one — so in practice `email`
    # here should always be a UW address. This check exists purely as a safety
    # net against bad/incomplete SDB data ever creating or updating a non-UW
    # GivePulse member (e.g. a community partner account) via this pipeline.
    unless domain.present? && UW_EMAIL_DOMAINS.include?(domain)
      Rails.logger.warn("Skipping student — non-UW email on record: #{email.inspect}")
      return { status: :skipped, email: email, reason: 'non_uw_email' }
    end

    begin
      # If we were already handed a StudentRecord, don't call #sdb again —
      # StudentRecord#sdb either returns self or triggers a redundant lookup.
      # Only Student instances need the extra hop to get to the SDB data.
      sdb_student           = student.is_a?(StudentRecord) ? student : student.sdb

      unless sdb_student
        Rails.logger.warn("Skipping student #{email} — no SDB record found.")
        return { status: :skipped, email: email, reason: "missing_sdb_record" }
      end
      admin_minor           = sdb_student.age < 18 ? "Yes" : "No"
      admin_dir_release     = sdb_student.dir_release ? "Yes" : "No"
      admin_campus          = (sdb_student.major_branch_list rescue '')
      admin_class_standing  = (sdb_student.class_standing_description(show_upcoming_graduation: true) rescue '')
      admin_student_major   = (sdb_student.majors_list(true, ", ") rescue '')

      admin_fields =
        if Rails.env.production?
          {
            "236072" => admin_minor,
            "236073" => admin_dir_release,
            "239467" => course_section,
            "268083" => admin_campus,
            "268084" => admin_class_standing,
            "268085" => admin_student_major,
            "276190" => Date.current.to_s
          }
        else
          {
            "81445" => admin_minor,
            "81773" => admin_dir_release,
            "82030" => course_section,
            "82591" => admin_campus,
            "82592" => admin_class_standing,
            "82593" => admin_student_major,
            "82641" => Date.current.to_s
          }
        end.compact # drop course_section key entirely when nil (non-course imports)

      user_params = {
        user: {
          first_name:            student.firstname,
          last_name:             student.lastname,
          email:                 email,
          administrative_fields: admin_fields,
          group_id:              group_id
        }
      }

      will_be_private = existing_emails && !existing_emails.include?(email)
      # Only mark as private if the user doesn't already exist in GivePulse.
      user_params[:user][:is_private] = 1 if will_be_private

      if dry_run
        Rails.logger.info(
          "[DRY RUN] Would add/update #{email} in group #{group_id} " \
          "(is_private: #{will_be_private ? 1 : 0}, admin_fields: #{admin_fields})"
        )
        # Note: existing_emails is intentionally NOT mutated here — a dry run
        # must not affect is_private decisions for subsequent students in the
        # same loop, since nothing was actually created in GivePulse.
        return { status: :would_add, email: email, reason: 'dry_run' }
      end

      response = request_api("/users", user_params, method: :post)

      if response.is_a?(Hash)
        Rails.logger.error("Failed to add student #{email}. Error: #{response[:error] || response}")
        return { status: :error, email: email, reason: response[:error] || response }
      end

      body = JSON.parse(response.body)

      unless response.code.to_i == 200 || body["updated"] == true || body["updated"] == 1
        Rails.logger.error("Failed to add student #{email}. Code: #{response.code}, Body: #{response.body}")
        return { status: :error, email: email, reason: body }
      end

      existing_emails << email if existing_emails
      Rails.logger.info("Successfully added #{email} to group #{group_id} (user_id: #{body['user_id']})")
      { status: :added, email: email, user_id: body['user_id'] }

    rescue StandardError => e
      Rails.logger.error("Exception adding student #{email}: #{e.class}: #{e.message}")
      { status: :error, email: email, reason: e.message }
    end
  end


  # Sync all Givepulse users in a group with updated admin fields from their SDB Student records
  # Example Use: GivepulseUser.sync_group_members(920703)
  def self.sync_group_members(group_id, offset: 0, limit: 200)
    batch_started_at = Time.now

    api_limit = [limit.to_i, 50].min
    api_offset = offset.to_i

    # Step 1: Fetch Givepulse users in the group
    page = fetch_records("/users", { group_id: group_id, limit: api_limit, offset: api_offset }) || { results: [], total: 0 }
    results = page[:results] || []
    total   = page[:total].to_i
    givepulse_users = results.map { |attrs| new(attrs.slice(*permitted_attrs)) }

    if givepulse_users.empty?
      duration = (Time.now - batch_started_at).round(2)
      message = "No Givepulse users found for group_id=#{group_id} offset=#{offset} limit=#{limit} (#{duration}s)."
      Rails.logger.warn(message)
      return { processed: 0, updated: 0, total: total, duration: duration, message: message }
    end

    total_users = givepulse_users.size
    updated_count = 0
    cutoff_date = 3.months.ago.to_date

    givepulse_users.each do |gp_user|
      synced_at_str = gp_user.administrative_fields.to_h["Sdb Synced At"]

      if synced_at_str.present?
        begin
          synced_at = Date.iso8601(synced_at_str) # "YYYY-MM-DD"
          next if synced_at >= cutoff_date
        rescue ArgumentError
          # If it's unparseable, treat as not present => proceed with sync
        end
      end

      # Step 2: Find matching Student by email
      email = gp_user.email.to_s.strip.downcase

      # Only sync UW emails; otherwise skip
      uw_domains = %w[uw.edu u.washington.edu]
      domain = email.split("@", 2).last

      unless domain.present? && uw_domains.include?(domain)
        Rails.logger.info("Skipping sync: non-UW email=#{email.inspect} givepulse_user_id=#{gp_user.id rescue 'unknown'}")
        next
      end

      uw_netid = email.split("@", 2).first
      if uw_netid.blank?
        Rails.logger.warn("Skipping sync: blank UW NetID parsed from email=#{email.inspect}")
        next
      end

      student =
        begin
          Student.find_by_uw_netid(uw_netid)
        rescue StandardError => e
          Rails.logger.error("Error finding Student by UW NetID #{uw_netid}: #{e.class}: #{e.message}")
          nil
        end

      unless student
        Rails.logger.warn("No matching Student found for UW NetID: #{uw_netid}")
        next
      end

      # Step 3: Prepare updated admin fields from Student
      admin_minor         = (student.sdb.age < 18) ? "Yes" : "No"
      admin_dir_release   = student.dir_release ? "Yes" : "No"
      admin_campus        = (student.major_branch_list rescue "")
      admin_class_standing = (student.sdb.class_standing_description(show_upcoming_graduation: true) rescue "")
      admin_student_major = (student.sdb.majors_list(true, ", ") rescue "")

      # Step 4: Build params for update_user
      admin_fields =
        if Rails.env.production?
          {
            "236072" => admin_minor,
            "236073" => admin_dir_release,
            "268083" => admin_campus,
            "268084" => admin_class_standing,
            "268085" => admin_student_major,
            "276190" => Date.current.to_s
          }
        else
          {
            "81445" => admin_minor,
            "81773" => admin_dir_release,
            "82591" => admin_campus,
            "82592" => admin_class_standing,
            "82593" => admin_student_major,
            "82641" => Date.current.to_s
          }
        end

      post_params = {
        user: {
          first_name: student.firstname,
          last_name: student.lastname,
          email: student.email,
          administrative_fields: admin_fields,
          group_id: group_id
        }
      }

      # Step 5: Call update_user on GivepulseUser instance
      success = gp_user.update_user(post_params)
      if success
        updated_count += 1
      else
        Rails.logger.error("Failed to update GivepulseUser for student #{student.email}")
      end
    end

    duration = (Time.now - batch_started_at).round(2)
    message = "Batch sync completed group_id=#{group_id} offset=#{api_offset} limit=#{api_limit} "\
            "processed=#{total_users} updated=#{updated_count} total=#{total} duration=#{duration}s"
    Rails.logger.info(message)

    { processed: total_users, updated: updated_count, total: total, duration: duration, message: message }
  end

  def fullname
    [first_name, middle_name, last_name].reject(&:blank?).join(' ')
  end


end