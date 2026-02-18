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
  # Example: GivepulseUser.where(group_id: 1479596)
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
  # example: GivepulseUser.find_by(id: 4228632).update_user({user: {administrative_fields: {"81773" => "Yes" }}})
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

  # Sync all Givepulse users in a group with updated admin fields from their SDB Student records
  # Example Use: GivepulseUser.sync_group_members(920703)
  def self.sync_group_members(group_id)
    # Step 1: Fetch Givepulse users in the group
    givepulse_users = where(group_id: group_id)

    if givepulse_users.empty?
      Rails.logger.warn("No Givepulse users found for group_id: #{group_id}")
    end

    total_users = givepulse_users.size
    updated_count = 0

    givepulse_users.each do |gp_user|
      # Step 2: Find matching Student by email
      # Extract UW NetID from email (string before '@')
      uw_netid = gp_user.email.to_s.split('@').first

      # Find Student by UW NetIDs
      begin
        student = Student.find_by_uw_netid(uw_netid)
        unless student
          Rails.logger.warn("No matching Student found for UW NetID: #{uw_netid}")
          next
        end
      rescue StandardError => e
        Rails.logger.error("Error finding Student by UW NetID #{uw_netid}: #{e.message}")
        next
      end

      # Step 3: Prepare updated admin fields from Student
      admin_minor = student.sdb.age < 18 ? "Yes" : "No"
      admin_dir_release = student.dir_release ? "Yes" : "No"
      admin_campus = student.major_branch_list rescue ''
      admin_class_standing = student.sdb.class_standing_description(show_upcoming_graduation: true) rescue ''
      admin_student_major = student.sdb.majors_list(true, ", ") rescue ''

      admin_fields = if Rails.env.production?
        {
          "236072" => admin_minor,
          "236073" => admin_dir_release,
          "268083" => admin_campus,
          "268084" => admin_class_standing,
          "268085" => admin_student_major
        }
      else
        {
          "81445" => admin_minor,
          "81773" => admin_dir_release,
          "82591" => admin_campus,
          "82592" => admin_class_standing,
          "82593" => admin_student_major
        }
      end

      # Step 4: Build params for update_user
      post_params = {
        user: {
          first_name: student.firstname,
          last_name: student.lastname,
          email: student.email,
          administrative_fields: admin_fields,
          group_id: group_id,
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

    message = "Sync completed for group_id: #{group_id}. Total users: #{total_users}, Successfully updated: #{updated_count}."
    Rails.logger.info(message)
    message

  end

  def fullname
    [first_name, middle_name, last_name].reject(&:blank?).join(' ')
  end


end