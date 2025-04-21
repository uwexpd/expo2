class AddInvisibleToApplicationPages < ActiveRecord::Migration[5.2]
  def change
    add_column :application_pages, :invisible, :boolean
  end
end
