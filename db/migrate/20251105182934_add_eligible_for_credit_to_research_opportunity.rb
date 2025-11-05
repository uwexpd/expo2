class AddEligibleForCreditToResearchOpportunity < ActiveRecord::Migration[5.2]
  def change
    add_column :research_opportunities, :eligible_for_credit, :boolean
  end
end
