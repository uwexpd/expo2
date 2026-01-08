class GivepulseGroup < GivepulseBase
  include ActiveModel::Model

  # Attributes for the Group
   attr_accessor :group_id,          # Integer - Return the details of a specific group. If not set, will search groups on the platform
                :is_admin_group,     # Integer - Filter for administrative groups. 0 = is not an administrative group. 1 = is an administrative group. Default: 0. Allowed: 0, 1
                :parent_id,          # Integer - Find all direct subgroups of parent_id
                :city,               # Integer - City of the group for which to return results
                :state,              # String - State of the group for which to return results
                :zip,                # String - Zipcode of the group for which to return results
                :tag,                # String - Tags in which the group has been tagged
                :query,              # String - Query for groups by title, description and search_keywords
                :title,              # String - Query for groups by just their title (fuzzy search)
                :description,        # String - Query for groups by just their description (fuzzy search)
                :search_keywords,    # String - Query for groups by just their search keywords (fuzzy search)
                :type                # String - Type (description missing)

  # Example: GivepulseGroup.where(parent_id: 1246545)
  # e.g.GivepulseGroup.where(group_id: 1861869)
  def self.where(attributes)
    begin
      results = fetch_all_records('/groups', attributes)

      if results.empty?
        Rails.logger.warn("No groups found with attributes: #{attributes}")
        []
      else
        results.map { |attrs| new(attrs.slice(*permitted_attrs)) }
      end
    rescue StandardError => e
      Rails.logger.error("Error fetching group: #{e.message}")
      []
    end
  end
    
  # params => {:user=>{:administrative_fields=>{"81445"=>"No"}}} 
  def update(params)
    return false unless id
      
    begin
        response =  GivepulseGroup.request_api("/groups/#{id}", params, method: :put)
        # Rails.logger.debug("Original Response received: #{response}")
        response = JSON.parse(response.body)
        # Rails.logger.debug("Json Response received: #{response}")

        if response['updated']==1
          params.each do |key, value|
            if respond_to?("#{key}=") # Ensure the attribute exists
              send("#{key}=", value)
            end
          end
          Rails.logger.info("Successfully update the group with ID: #{id}")
          true
        else
          Rails.logger.warn("Failed to update group with ID #{id}: #{response}")
          false
        end
    rescue StandardError => e
        Rails.logger.error("Error updating group: #{e.message}")
        false
    end    
  end  


end