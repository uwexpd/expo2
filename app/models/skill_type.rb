class SkillType < ApplicationRecord
  stampable
  validates :title, presence: true
end