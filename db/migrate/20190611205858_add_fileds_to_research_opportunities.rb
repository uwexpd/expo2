class AddFiledsToResearchOpportunities < ActiveRecord::Migration
  def change
    add_column :research_opportunities, :submitted_at, :datetime
    add_column :research_opportunities, :submitted_person_id, :integer
    add_column :research_opportunities, :paid, :boolean
    add_column :research_opportunities, :work_study, :boolean
    add_column :research_opportunities, :location, :string
  end
end
