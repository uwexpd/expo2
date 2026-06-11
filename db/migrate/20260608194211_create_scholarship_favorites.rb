class CreateScholarshipFavorites < ActiveRecord::Migration[5.2]
   def change
    create_table :scholarship_favorites do |t|
      t.integer    :user_id,        null: false  # int(11) to match users.id
      t.integer    :scholarship_id, null: false  # plain integer — no FK (scholarship is on a separate DB)
      t.timestamps
    end

    # Match the int(11) type on users.id
    add_foreign_key :scholarship_favorites, :users, column: :user_id

    # Prevent a user from favoriting the same scholarship twice
    add_index :scholarship_favorites, [:user_id, :scholarship_id], unique: true
    # Index for lookups by scholarship (e.g. "how many users favorited this?")
    add_index :scholarship_favorites, :scholarship_id
  end
end
