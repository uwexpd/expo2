class SocialIssueType < ApplicationRecord
  stampable
  validates :title, presence: true
end