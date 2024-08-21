class AddAvailabilityAndSocialToResearchOpportunity < ActiveRecord::Migration[5.2]
  def change
    add_column :research_opportunities, :availability, :string    
    add_column :research_opportunities, :social, :boolean
    add_column :research_opportunities, :social_if_yes, :string
  end
end
