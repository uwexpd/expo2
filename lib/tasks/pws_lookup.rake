# frozen_string_literal: true

require 'csv'
require 'caxlsx'
require 'set'

namespace :pws do
  desc "Read a CSV with an email column, lookup PWS by netid, and export XLSX (Name, Email, Department).
        Usage:
          rake pws:from_csv['input.csv']                                   # writes input_pws.xlsx in same dir
          rake pws:from_csv['input.csv','output.xlsx']                     # choose output path
          rake pws:from_csv['input.csv','output.xlsx',work_email]          # custom email header
          rake pws:from_csv['input.csv','output.xlsx',email,0.1,true]      # throttle + dry-run
  "
  task :from_csv, [:input_csv, :output_xlsx, :email_header, :throttle, :dry_run] => :environment do |_t, args|
    # ---------- Arguments ----------
    input_csv    = args[:input_csv].to_s
    if input_csv.empty?
      puts "ERROR: Provide input CSV. Example: rake pws:from_csv['tmp/users.csv']"
      exit 1
    end
    default_out  = File.join(File.dirname(input_csv), "#{File.basename(input_csv, '.*')}_pws.xlsx")
    output_xlsx  = (args[:output_xlsx].presence || default_out).to_s
    email_header = (args[:email_header].presence || 'email').to_s.strip.downcase
    throttle     = (args[:throttle].presence || '0').to_f
    dry_run      = ActiveModel::Type::Boolean.new.cast(args[:dry_run])

    # ---------- Validate IO ----------
    unless File.exist?(input_csv)
      puts "ERROR: CSV not found: #{input_csv}"
      exit 1
    end
    out_dir = File.dirname(output_xlsx)
    unless Dir.exist?(out_dir)
      puts "ERROR: Output directory does not exist: #{out_dir}"
      exit 1
    end

    puts "Starting PWS lookup"
    puts "  input_csv:    #{input_csv}"
    puts "  output_xlsx:  #{output_xlsx}"
    puts "  email_header: #{email_header}"
    puts "  throttle:     #{throttle}s"
    puts "  dry_run:      #{dry_run}"

    # ---------- Helpers (scoped to task) ----------
    normalize_header = ->(h) { h.to_s.strip.downcase }
    safe_string = ->(v) do
      v = '' if v.nil?
      v = v.to_i.to_s if v.is_a?(Float)
      v.to_s.strip
    end
    extract_netid = ->(email) do
      s = safe_string.call(email).downcase
      return nil unless s.include?('@') && s.index('@').between?(1, s.length - 2)
      local = s.split('@', 2).first
      return nil unless local =~ /\A[[:alnum:]][[:alnum:]._+-]*\z/
      local
    end

    # ---------- Read CSV ----------
    rows = []
    headers = nil
    CSV.foreach(
      input_csv,
      headers: true,
      return_headers: false,
      encoding: 'bom|utf-8',
      header_converters: ->(h) { normalize_header.call(h) }
    ) do |row|
      headers ||= row.headers
      rows << row.fields
    end

    header_index = headers.each_with_index.to_h # {"email" => 2, ...}
    email_idx = header_index[email_header]
    if email_idx.nil?
      puts "ERROR: CSV missing required email header '#{email_header}'. Found: #{headers.join(', ')}"
      exit 1
    end

    # ---------- Build email/netid list and de-dupe netids ----------
    total_rows   = rows.size
    row_email_netid = []   # [{email:, netid:}] aligned to CSV
    skipped_rows = []      # [{row: csv_row_number, reason: "..."}]

    rows.each_with_index do |r, i|
      raw_email = safe_string.call(r[email_idx])
      if raw_email.empty?
        skipped_rows << { row: i + 2, reason: 'blank email' }
        row_email_netid << { email: nil, netid: nil }
        next
      end

      netid = extract_netid.call(raw_email)
      if netid.nil?
        skipped_rows << { row: i + 2, reason: "invalid email: #{raw_email.inspect}" }
      end
      row_email_netid << { email: raw_email, netid: netid }
    end

    unique_netids = row_email_netid.map { |h| h[:netid] }.compact
    # preserve order and remove duplicates
    seen = Set.new
    unique_netids.select! { |nid| seen.add?(nid) }

    # ---------- PWS lookups ----------
    netid_to_person = {} # netid => { name:, department: }
    unresolved      = [] # [{ netid:, error: "..."}]

    unless dry_run      

      unique_netids.each_with_index do |netid, idx|
        begin
          # Get PWS INFO
          person = PersonResource.find_full_by_uw_netid(netid)

          if person.nil?
            unresolved << { netid: netid, error: 'not found' }
          else
            netid_to_person[netid] = {
              name:       person.display_name,
              email:      person.employee_email_addresses.join(', '),
              department: person.employee_home_department
            }
          end
        rescue StandardError => e
          unresolved <<({ netid: netid, error: "#{e.class} - #{e.message}" })
        ensure
          sleep(throttle) if throttle.positive?
        end
      end
    end

    # ---------- Build output rows (Name, Email, Department) ----------
    output_rows = []
    row_email_netid.each do |item|
      email = item[:email]
      netid = item[:netid]
      next if email.nil? || netid.nil?

      info = netid_to_person[netid]
      output_rows << [
        info&.dig(:name),        # Name
        email,                   # Email (from CSV)
        info&.dig(:department)   # Department
      ]
    end

    # ---------- Write XLSX (unless dry_run) ----------
    if dry_run
      puts "\nDry-run: would write #{output_rows.size} rows to #{output_xlsx}"
      puts "First 10 preview:"
      output_rows.first(10).each { |r| puts "  #{r.inspect}" }
    else
      pkg = Axlsx::Package.new
      wb  = pkg.workbook

      wb.styles do |s|
        header_style = s.add_style(b: true, alignment: { horizontal: :center }, bg_color: 'DDDDDD')
        wrap_style   = s.add_style(alignment: { wrap_text: true })
        error_style  = s.add_style(fg_color: 'FF0000')

        wb.add_worksheet(name: 'PWS Results') do |sheet|
          sheet.add_row ['Name', 'Email', 'Department'], style: header_style
          output_rows.each { |row| sheet.add_row row }
          sheet.auto_filter = 'A1:C1'
          sheet.column_widths 28, 36, 32
          sheet.sheet_view.pane do |pane|
            pane.top_left_cell = 'A2'
            pane.state = :frozen_split
            pane.y_split = 1
          end
        end

        if skipped_rows.any?
          wb.add_worksheet(name: 'Skipped Rows') do |sheet|
            sheet.add_row ['CSV Row #', 'Reason'], style: header_style
            skipped_rows.each { |srow| sheet.add_row [srow[:row], srow[:reason]], style: [nil, wrap_style] }
            sheet.column_widths 12, 80
          end
        end

        if unresolved.any?
          wb.add_worksheet(name: 'Unresolved NetIDs') do |sheet|
            sheet.add_row ['NetID', 'Error'], style: header_style
            unresolved.each { |u| sheet.add_row [u[:netid], u[:error]], style: [nil, error_style] }
            sheet.column_widths 24, 80
          end
        end
      end

      pkg.serialize(output_xlsx)
      puts "Wrote XLSX: #{output_xlsx}"
    end

    # ---------- Summary ----------
    puts "\n----- Summary -----"
    puts "CSV rows:        #{total_rows}"
    puts "Unique netids:   #{unique_netids.size}"
    puts "Resolved:        #{netid_to_person.size}"
    puts "Unresolved:      #{unresolved.size}"
    puts "Skipped rows:    #{skipped_rows.size}"
    puts "Output:          #{dry_run ? '(dry-run, not written)' : output_xlsx}"
    puts "------------------"
  rescue ArgumentError => e
    warn "ERROR: #{e.message}"
    exit 1
  rescue StandardError => e
    warn "Unexpected error: #{e.class} - #{e.message}"
    warn e.backtrace.first(5).join("\n")
    exit 1
  end
end