require 'carrierwave/orm/activerecord'

CarrierWave.configure do |config|  
  config.permissions = 0644
  config.directory_permissions = 0755
  config.storage = :file
  # This avoids uploaded files from saving to public/ and so
  # they will not be available for public (non-authenticated) downloading
  config.root = Rails.root
end