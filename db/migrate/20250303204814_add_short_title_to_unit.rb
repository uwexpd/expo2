class AddShortTitleToUnit < ActiveRecord::Migration[5.2]
  def change
    add_column :units, :short_title, :string
  end
end
