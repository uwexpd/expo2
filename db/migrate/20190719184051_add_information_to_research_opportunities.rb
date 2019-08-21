class AddInformationToResearchOpportunities < ActiveRecord::Migration
  def change
    add_column :research_opportunities, :learning_benefit, :text
  end
end
