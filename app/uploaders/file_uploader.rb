class FileUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Keep uploaded files FIXME: seems not working
  configure do |config|
    config.remove_previously_stored_files_after_update = false
  end
   # in `class PhotoUploader`
  before :cache, :save_original_filename
  process :save_content_type_and_size_in_model

  # Choose what kind of storage to use for this uploader:
  storage :file

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "files/application_file/#{mounted_as}/#{model.application_for_offering.id}"  
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url(*args)
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process scale: [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process resize_to_fit: [50, 50]
  # end

  # Add an allowlist of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_allowlist
    %w(pdf gif jpg jpeg png xls xlsx)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    "#{model.application_for_offering.id.to_s}-#{model.title.gsub(/[\s,\.\\\/\*\?\%\:\|\"\'\<\>]?/,'')}.#{file.extension}" unless file.nil?
  end

  def save_original_filename(file)
    model.original_filename ||= file.original_filename if file.respond_to?(:original_filename)
  end

  def save_content_type_and_size_in_model
    model.file_content_type = file.content_type if file.content_type
    model.file_size = file.size
  end

end
