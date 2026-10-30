class AddOrderingToEventStaffPositions < ActiveRecord::Migration[6.1]
  def change
    add_column :event_staff_positions, :ordering, :integer
  end
end
