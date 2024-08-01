class AddConfirmPrimaryToApplicationMentors < ActiveRecord::Migration[5.2]
  def change
    add_column :application_mentors, :confirm_primary, :boolean
  end
end
