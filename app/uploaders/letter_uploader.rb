class LetterUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick
  include PDFRender

  # Keep uploaded files FIXME: seems not working
  configure do |config|
    config.remove_previously_stored_files_after_update = false
  end
  
  # before :cache, :save_original_filename
  process :save_content_type_and_size_in_model

  # Choose what kind of storage to use for this uploader:
  storage :file

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "files/application_mentor/#{mounted_as}/#{model.id}"
  end

  def cache_dir
    "files/tmp/application_mentor_cache"
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
  version :unstamped do
    process :stamp_pdf!
  end

  # Add an allowlist of extensions which are allowed to be uploaded.
  def extension_allowlist
    %w(pdf gif jpg jpeg png xls xlsx doc docx)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    "#{model.id.to_s}-Letter.#{file.extension}" unless file.nil?
  end

  def filepath
    "#{Rails.root}/files/application_mentor/letter/#{model.id.to_s}/#{filename}"
  end

  # def save_original_filename(file)
  #   model.original_filename ||= file.original_filename if file.respond_to?(:original_filename)
  # end

  def save_content_type_and_size_in_model
    model.letter_content_type = file.content_type if file.content_type
    model.letter_size = file.size
  end  

end
