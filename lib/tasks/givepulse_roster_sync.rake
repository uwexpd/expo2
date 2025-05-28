desc "Daily sync Community Engaged course roster to UW GivePuse."
    task :givepulse_rouster_sync => :environment do
        current_quarter = Quarter.current_quarter
    	
        puts "#{current_quarter.abbrev} Course roster sync starts..."
        
        # Get GP CE courses with current quarter:
        ce_courses =  GivepulseCourse.find_by(term: current_quarter.abbrev)

        if ce_courses.blank?
            puts "No courses found for current quarter."
          
        else
            puts "Found courses: #{ce_courses.collect(&:crn).join(', ')}"

        	ce_courses.each do |gp_course|
                gp_course.add_students
                puts "Sucessfully synced #{gp_course.crn} #{gp_course.course_students.size} students."
            end
        end

    end
