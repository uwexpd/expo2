require 'hexapdf'
require 'wicked_pdf'
require 'fileutils'

=begin
  Creates or retrieves a custom composite report pertaining to an ApplicationForOffering. Each application has access to this functionality through the +composite_report+ method. There is only one public method, +pdf+, which takes paramaters of the application parts that should be included in the PDF report. Options are:
  
  * :scoring - A scoring/comment sheet that can be used by reviewers.
  * :application_review - Uses HTMLDoc to duplicate the "Application Details" tab.
  * :files - All files (usually essays) that the applicant uplaoded. Auto-generates the PDF version if needed.
  * :mentor_letters - All letters that the applicant's mentor(s) uplaoded. Auto-generates the PDF version if needed.
  * :transcript - Uses HTMLDoc to duplicate the transcript display on the "Transcript" tab.
  * :all - includes all of the above
=end
class ApplicationCompositeReport
  def initialize(application_for_offering, application_reviewer = nil, offering_interview_interviewer = nil)
    @application_for_offering = application_for_offering
    @application_reviewer = application_reviewer
    @offering_interview_interviewer = offering_interview_interviewer
  end

  def pdf(*include_parts)
    include_parts = [:application_review, :files, :mentor_letters, :transcript, :scoring] if include_parts == [:all]
    include_parts = reorder_parts(include_parts)    

    # Return a cached version if it exists
    if !stale?(include_parts)
      puts "Returning cached report file"
      puts "   Report created: #{File.mtime(report_filename(include_parts)) rescue "never"}"
      puts "   Application updated: #{@application_for_offering.updated_at}"
      return report_filename(include_parts)
    end

    # For each part of the application, get or generate the filenames of the PDF files we'll be combining.
    parts = include_parts.flatten.map do |part| 
      result = get_part(part)
      result.is_a?(Array) ? result : [result]
    end.flatten.compact
    # puts "Get parts filenames => #{parts.inspect}"

    # Check that the parts filenames exist
    parts.delete_if {|p| !File.exists?(p.to_s) }
    puts "ERROR: No files to combine" if parts.empty?

    puts "Combining the following files:"
    parts.each{|p| puts "   #{p}"}

    # Combine the PDFs together into one report
    output = report_filename(include_parts)
    verify_file_path(output)

    # Merge part PDFs
    # puts "Outputting to:"; puts "   #{output}"    
    command = "hexapdf merge #{parts.map(&:to_s).join(" ")} #{output}"
    puts "Command => #{command}"

    # Execute the command
    success = system(command)
    if success
      puts "Successfully generated report."
      return output
    else
      puts "Error creating report file: #{$?} #{command}"
      return $?
    end
  end

  def stale?(include_parts)
    return true unless exists?(include_parts)

    filetime = File.mtime(report_filename(include_parts))
    return true if filetime < @application_for_offering.updated_at

    if @application_reviewer && include_parts.include?(:scoring)
      return true if filetime < @application_reviewer.updated_at
    end

    if @offering_interview_interviewer && include_parts.include?(:scoring)
      return true if filetime < @offering_interview_interviewer.updated_at
    end

    false
  end

  def exists?(include_parts)
    File.exists?(report_filename(include_parts))
  end

  def get_part(part)
    case part
    when :stamp
      generate_pdf_stamp!
    when :application_review
      generate_part!(part)
    when :scoring
      generate_part!(part)
    when :transcript
      generate_part!(part)
    when :files
      @application_for_offering.files.map{ |f| f.file.filepath }
    when :mentor_letters
      @application_for_offering.mentors.map{ |m| m.letter.filepath }
    end
  end

  def part_filename(part)
    if part == :scoring
      reviewer_bits = []
      reviewer_bits << "r#{@application_reviewer.id.to_s}" if @application_reviewer
      reviewer_bits << "i#{@offering_interview_interviewer.id.to_s}" if @offering_interview_interviewer
    end
    part_name = part == :scoring ? "scoring_#{reviewer_bits.join('_')}" : part.to_s
    Rails.root.join('files', 'application_composite_report', @application_for_offering.id.to_s, 'parts', "#{part_name}.pdf")
  end

  def report_filename(include_parts)
    reviewer_bits = []
    reviewer_bits << "r#{@application_reviewer.id}" if @application_reviewer
    reviewer_bits << "i#{@offering_interview_interviewer.id}" if @offering_interview_interviewer
    basename = "Report_#{@application_for_offering.id}#{reviewer_bits.join('_')}_#{include_parts.hash}.pdf"
    File.join(Rails.root, "files", "application_composite_report", @application_for_offering.id.to_s, basename)
  end

  protected

  def generate_part!(part)
    puts "Generating part: #{part}"
    data = case part
           when :transcript
             render_partial('admin/applications/transcript', print_only: true, audience: :reviewer)
           when :application_review
             render_partial('admin/applications/question_review', audience: :download)
           when :scoring
             render_partial('admin/applications/scoring')
           end
    verify_file_path(part_filename(part))
    pdf = WickedPdf.new.pdf_from_string(data,
                                    page_size: 'Letter',
                                    margin: { bottom: 20, top: 20 },
                                    footer: { left: "#{part.to_s.split.map(&:capitalize).join(' ') }", right: '[page] of [topage]'},
                                    )
    File.open(part_filename(part), 'wb') do |file|
      file.write(pdf)
    end
    stamp_pdf!(part_filename(part))
  end

  def generate_pdf_stamp!
    # stamp_content = <<~EOF
    #   <div style="position: absolute; top: 10px; left: 20px; font-size: 9px;">
    #     #{@application_for_offering.offering.title}
    #   </div>
    #   <div style="position: absolute; top: 20px; left: 20px; font-size: 11px;">
    #     <b>Applicant: #{@application_for_offering.fullname}</b>
    #   </div>
    #   <div style="position: absolute; top: 30px; right: 20px; font-size: 11px; color: red;">
    #     <b>CONFIDENTIAL</b>
    #   </div>
    #   <div style="position: absolute; top: 40px; right: 20px; font-size: 7px;">
    #     Destroy by #{@application_for_offering.offering.destroy_by}
    #   </div>
    # EOF

    # pdf = WickedPdf.new.pdf_from_string(stamp_content)
    # stamp_path = part_filename(:stamp)
    # File.open(stamp_path, 'wb') do |file|
    #     file.write(pdf)
    # end
    # stamp_path

    # Using HexaPDF to create stamped PDF
    verify_file_path(part_filename(:stamp))
    composer = HexaPDF::Composer.new(page_size: :Letter, margin: 20) do |pdf|
      pdf.text("#{@application_for_offering.offering.title}", font: 'Helvetica', font_size: 9, position: :float)
      pdf.text("CONFIDENTIAL", font: ['Helvetica', variant: :bold], font_size: 11, fill_color: 'red', align: :right)
      pdf.text("Applicant: #{@application_for_offering.fullname}", font: ['Helvetica', variant: :bold], font_size: 11, line_height: 10, position: :float)
      pdf.text("Destroy by #{@application_for_offering.offering.destroy_by}", font: 'Helvetica', font_size: 7, align: :right)
    end
    stamp_path = part_filename(:stamp)
    File.open(stamp_path, 'wb') do |file|
        composer.write(file)
    end
    stamp_path

  end

  def stamp_pdf!(file)
    stamped_file = file.sub('.pdf', '-stamped.pdf')
    command = "hexapdf watermark -w #{get_part(:stamp)} -t stamp #{file} #{stamped_file}"
    success = system(command)
    if success
      File.rename(stamped_file, file) 
    else
      puts "Error stamp the PDF file: #{$?} #{command}"
    end
    file
  end

  def render_partial(partial, locals = {})
    puts "   Rendering partial: #{partial}"
    ApplicationController.render(partial: partial, locals: locals, assigns: { app: @application_for_offering })    
  end

  def verify_file_path(file)
    FileUtils.mkdir_p(File.dirname(file)) unless File.exists?(File.dirname(file))
  end

  def reorder_parts(parts)
    order = { scoring: 0, application_review: 1, files: 2, mentor_letters: 3, transcript: 4 }
    ordered_parts = []
    parts.flatten.each{|p| ordered_parts.insert(order[p], p)}
    ordered_parts.compact    
  end

  def puts(s)
    Rails.logger.info(s) unless Rails.logger.nil?    
  end

end
