class AddTimeConflictsToApplicationForOffering < ActiveRecord::Migration[5.2]
  def change
    add_column :application_for_offerings, :time_conflicts, :string
  end
end
