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

  # Simulate ActiveRecord's find_by method
  # Example: GivepulseUser.find_by(group_id: '757578', user_id: '4228632') Sendbox data
  def self.where(attributes)
    begin
      # response = make_request('/users', attributes)
      response = request_api('/users', attributes, method: :get)
      response = JSON.parse(response.body)

      if response['total'].to_i > 0
        results = response['results']        
        users = results.map { |attrs| build_user(attrs) }
        return users.first if users.size == 1
        users
      else
        Rails.logger.warn("No users found with attributes: #{attributes}")
        nil
      end
    rescue StandardError => e
      Rails.logger.error("Error fetching users: #{e.message}")
      nil
    end
  end

  # Alias `where` to `find_by`
  def self.find_by(attributes)
    where(attributes)
  end
    
  # params => {:user=>{:administrative_fields=>{"81445"=>"No"}}} 
  def update_user(params)
    return false unless id
      
    begin
        response = request_api("/users/#{id}", params, method: :put)
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


  def fullname
    [first_name, middle_name, last_name].reject(&:blank?).join(' ')
  end

  private

  def self.build_user(attrs)
    GivepulseUser.new(attrs)
  end  


end