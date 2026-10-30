class AddCapacityToEventStaffPositionShifts < ActiveRecord::Migration[6.1]
  def change
    add_column :event_staff_position_shifts, :capacity, :integer
  end
end
