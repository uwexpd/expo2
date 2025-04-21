class AddNonStudentToOffering < ActiveRecord::Migration[5.2]
  def change
    add_column :offerings, :non_student, :boolean
  end
end
