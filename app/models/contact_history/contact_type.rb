class ContactType < ApplicationRecord
  stampable
  
  def <=>(o)
    title <=> o.title
  end
  
end
