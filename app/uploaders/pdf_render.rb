module PDFRender
  # Adds the PDF stamp to the requested file 
  # Use hexapdf watermark command line
  # e.g. $hexapdf watermark -w stamp-compsesr.pdf -t stamp to-be-stamped.pdf output.pdf
  def stamp_pdf!
    stamp_filename = model.application_for_offering.composite_report.get_part(:stamp)
    # Rails.logger.debug "Debug: #{self.cache_name}, #{self.cache_path(self.original_filename)}"
    cache_file_path = self.cache_path(self.original_filename)

    command = "hexapdf watermark -w #{stamp_filename} -t stamp #{cache_file_path} #{cache_file_path}-stamped"
    Rails.logger.info { "Stamping PDF file:\n   #{command}"}

    res = `#{command}`
    output = $?
      if output.success?
        `mv #{cache_file_path} #{cache_file_path}-unstamped`
        `mv #{cache_file_path}-stamped #{cache_file_path}`
      end
    return output
  end
end
