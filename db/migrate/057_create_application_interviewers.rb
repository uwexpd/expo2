class CreateApplicationInterviewers < ActiveRecord::Migration
  def self.up
    create_table :application_interviewers do |t|
      t.integer :application_for_offering_id
      t.integer :person_id

      t.timestamps
    end
  end

  def self.down
    drop_table :application_interviewers
  end
end
