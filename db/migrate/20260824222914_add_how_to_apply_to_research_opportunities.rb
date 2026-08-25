class AddHowToApplyToResearchOpportunities < ActiveRecord::Migration[6.1]
  def change
    add_column :research_opportunities, :how_to_apply, :text
  end
end
