class CreateScholarshipMonthlyDeadlines < ActiveRecord::Migration[5.2]
  def change
    create_table :scholarship_monthly_deadlines do |t|
      t.integer :scholarship_id
      t.text :title
      t.integer :deadline_month
      t.boolean :is_active          
    end
  end
end
