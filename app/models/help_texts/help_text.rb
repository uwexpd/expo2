# Used for storing bits of help text in the database so that admin users can control it without changing code.
# 
# ModelHelpTexts can be connected to a model and attribute; plain HelpTexts are simply defined with a unique key.
class HelpText < ApplicationRecord
  stampable

  validates :key, presence: true, unless: ->(t) { t.is_a?(ModelHelpText) }
  validates :key, uniqueness: { scope: :object_type }, unless: ->(t) { t.is_a?(ModelHelpText) }

  # Returns the caption for the HelpText with the specified key and object type. Object type is optional.
  def self.caption(key, object_type = nil)
    ht = find_by(key: key.to_s, object_type: object_type.to_s)
    ht&.caption
  end
end