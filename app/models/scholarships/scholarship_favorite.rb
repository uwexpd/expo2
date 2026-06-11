class ScholarshipFavorite < ApplicationRecord
  belongs_to :user
  # No belongs_to :scholarship — it lives on a separate DB connection.
  # scholarship_id is stored as a plain integer.

  validates :scholarship_id, presence: true
  validates :user_id, uniqueness: { scope: :scholarship_id,
                                    message: "has already favorited this scholarship" }
end
