require 'hexapdf'
require 'wicked_pdf'
require 'fileutils'

=begin
  Creates a zipped file package containing ApplicationCompositeReport files for all of the requested user applications.
=end
class MultiApplicationCompositeReport
  
  # The +new+ method accepts two parameters: an array of ApplicationForOffering objects and an array of which parts to include in
  # the reports. The parts can include these options:
  # 
  # * :application_review - Uses HTMLDoc to duplicate the "Application Details" tab.
  # * :files - All files (usually essays) that the applicant uplaoded. Auto-generates the PDF version if needed.
  # * :mentor_letters - All letters that the applicant's mentor(s) uplaoded. Auto-generates the PDF version if needed.
  # * :transcript - Uses HTMLDoc to duplicate the transcript display on the "Transcript" tab.
  # * :all - includes all of the above.
  def initialize(offering = nil, apps = [], *include_parts)
    
    # Delete any non-ApplicationForOffering objects and raise exception if the resulting list is empty
    apps.delete_if {|a| !a.is_a?(ApplicationForOffering) }
    raise Exception.new("No valid applications specified") and return if apps.empty?
    
    # Store instance variables
    @offering = offering
    @apps = apps
    @include_parts = include_parts
    @review_committee_member = nil
    @offering_interviewer = nil
    
    # Allow for an ":all" parameter
    @include_parts = [:application_review, :files, :mentor_letters, :transcript] if @include_parts == [:all]
    
    puts "Creating composite report with the following parts for #{@apps.size} applications:"
    puts "   #{@include_parts.join(", ")}"
    
  end

  def review_committee_member=(member)
    @review_committee_member = member
  end

  def offering_interviewer=(interviewer)
    @offering_interviewer = interviewer
  end

  # Generates the actual zip file (or returns the cached version if available)
  def generate!(output_type = :zip)
    files = []
    stale = false  # keep track if any reports are stale so we know if we need to regenerate the final file
    
    # For each app, fetch the filename for the report and populate the +files+ array
    for app in @apps
      application_reviewer = app.reviewers.find_by_committee_member_id(@review_committee_member) if @review_committee_member
      if (@offering_interviewer)
        oi = app.offering_interviews.first
        offering_interview_interviewer = @offering_interviewer.offering_interview_interviewers.find_by_offering_interview_id(oi)
      end
      report = app.composite_report(application_reviewer, offering_interview_interviewer)
      file = report.pdf(@include_parts)
      files << file if file.is_a?(String)
      stale = true if report.stale?(@include_parts)
      puts "Adding to file list: #{report.pdf(@include_parts)}#{" (stale)" if stale}" if report.exists?(@include_parts)
#      @apps.delete(app) if report.exists?(@include_parts)
    end
    # raise Exception.new("No files exist to zip") if files.empty?
    
    # Generate the cover sheet PDF and insert it into the files array
    files.insert(0, generate_cover!(@apps))
    
    # Generate the zip file and return the filename
    if stale || !File.exists?(filename(output_type))
      # FileUtils.mkdir_p(File.dirname(filename(output_type))) unless File.exists?(File.dirname(filename(output_type)))
      FileUtils.mkdir_p(File.dirname(filename(output_type)))
      puts "Ready to combine #{files.size} files:"; files.each{|f| puts "   #{f}"}
      puts "Outputting to:"; puts "   #{filename(output_type)}"
      files_list = files.map(&:to_s).join(" ")
      # puts "files_list => #{files_list.inspect}"
      command = case output_type
      when :zip
        "zip -r -j #{filename(output_type)} #{files_list}"
      when :pdf
        "hexapdf merge #{files_list} #{filename(output_type)}"
      end
      puts "Command for multi apps report => #{command}"
      success = system(command)
      if success
        puts "Successfully generated report package."
        return filename(output_type)
      else
        return $?
      end
    else
      return filename(output_type)
    end
  end
  
  protected
  
  def filename(output_type = :zip)
    ext = output_type.to_s
    reviewer_bit = "_r#{@review_committee_member.id.to_s}" if @review_committee_member
    interviewer_bit = "_i#{@offering_interviewer.id.to_s}" if @offering_interviewer
    basename = "applications_#{@apps.hash.to_s}#{reviewer_bit.to_s}#{interviewer_bit.to_s}_#{@include_parts.hash.to_s}.#{ext}"    
    File.join(Rails.root, "files", "multi_application_composite_report", @apps.hash.to_s, basename)
  end

  def cover_filename
    # Create a unique basename using the hashes of @apps and @include_parts
    basename = "cover_#{@apps.hash}_#{@include_parts.hash}.pdf"
      
    File.join(Rails.root, "files", "multi_application_composite_report", @apps.hash.to_s, basename)
  end

  
  def generate_cover!(apps)
    puts "Generating PDF cover sheet (#{apps.size} applications)"    

    # Initialize HexaPDF Composer for layout management
    composer = HexaPDF::Composer.new(page_size: :Letter)

    # Start a new page
    composer.page

    # Add the "CONFIDENTIAL" header with red color and bold font
    composer.text("#{@offering.title}\n\n\n\n", font: 'Helvetica', font_size: 9, position: :float )
    composer.text("CONFIDENTIAL", font: ['Helvetica', variant: :bold], font_size: 9, fill_color: 'red', align: :right)
    composer.text("Destroy by #{@offering.destroy_by}\n\n\n\n", font: 'Helvetica', font_size: 7, align: :right)    
    
    composer.text("Application Review Packet\n\n", font: ['Helvetica', variant: :bold], font_size: 13)
    composer.text("This packet includes the following application parts:\n\n", font_size: 11)
    composer.text(@include_parts.join(", ") + "\n\n\n", font: ['Helvetica', variant: :italic], font_size: 9)    
    composer.text("Applications included:\n\n", font_size: 11)

    # List each application
    apps.each_with_index do |app, i|
      composer.text("#{(i+1).to_s.rjust(3)}.   #{app.fullname}\n\n\n", font_size: 11)
    end

    # Save the PDF file
    begin
      FileUtils.mkdir_p(File.dirname(cover_filename))
      composer.write(cover_filename, optimize: true)
      if File.exist?(cover_filename)
        puts "         #{cover_filename}"
        cover_filename
      else
        puts "   ERROR: File was not created"
        nil
      end
    rescue => e
      puts "   ERROR: #{e.message}"
      nil
    end
  end
  
  def puts(s)
    Rails.logger.info(s) unless Rails.logger.nil?    
  end
  
end