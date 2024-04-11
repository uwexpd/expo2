#For the following quarters: AUT 21, WIN 22, SPR 22, AUT 22, WIN 23, SPR 23, AUT 23, WIN 24
#Every DIV course, tri-campus.Course info: Abbreviation, number, title, credits, #enrolled, enrollment capacity, room capacity, has prerequisite yes/no, instructor. name, instructor email

# https://metadata.uw.edu/catalog/viewitem/Table/uwsdbdatastore.timeschedule

require 'axlsx'

desc "Run SDB course queries"
  task :div_courses => :environment do
	
	quarters = Quarter.where(id: [394, 395, 396, 398, 399, 400, 402, 403])
	puts "Quarters are #{quarters.collect(&:title)}"

	# Create a new workbook
	workbook = Axlsx::Package.new

	quarters.each do |quarter|
		div_courses = quarter.diversity_courses
		# puts "There are #{div_courses.size} courses in #{quarter.title}"

		# Add a worksheet
		workbook.workbook.add_worksheet(name: "#{quarter.title}") do |sheet|
		  # Add data to the sheet
		  sheet.add_row ['Abbreviation','Number', 'Short title', 'Course Title','Credits','#Enrolled','Enrollment Capacity','Room Capacity', 'Instructor Name', 'Instructor Email', 'Has Prerequiste', 'Course Description']

		  div_courses.each do |c|
		  	course_instrutors = c.course_meeting_times.first.course_instructors
		  	instructor_names = course_instrutors.collect{|ci| ci.instructor.fullname }.join(" | ")
		  	instructor_emails = course_instrutors.collect{|ci| ci.instructor.email }.join(" | ")
		  	course_prereq = c.prerequisites.size > 0 ? "yes" : "no"
		  	puts "#{c.prerequisites.first.title} => #{c.prerequisites.collect(&:prereq_course)}" if c.prerequisites.size > 0

		  	# puts "debug => #{c.ts_year}, #{c.quarter.quarter_code.name}, #{c.dept_abbrev.strip}, #{c.course_no}"		  	
		  	course_resource =CourseResource.find_by_course(c.ts_year.to_s, c.quarter.quarter_code.name, c.dept_abbrev.strip, c.course_no.to_s)
		  	course_description =  course_resource['CourseDescription'] if course_resource

		  	sheet.add_row [c.dept_abbrev, c.course_no, c.short_title, c.course_title, c.credit_minimum.to_i, c.current_enroll, c.l_e_enroll, c.room_cap, instructor_names, instructor_emails, course_prereq, course_description]
		  end
		end
	end
	# Save the workbook to a file
	workbook.serialize('outputs/div_courses_updated.xlsx')

	puts 'Spreadsheet generated successfully!'

	
  end
