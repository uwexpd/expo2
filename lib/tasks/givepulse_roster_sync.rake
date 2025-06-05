desc "Daily sync Community Engaged course roster to UW GivePuse."
    task :givepulse_rouster_sync => :environment do
        sync_quarters = [Quarter.current_quarter, Quarter.current_quarter.next]
    	
        puts "#{sync_quarters.collect(&:abbrev)} Course roster sync starts..."
        
        # Get GP CE courses with sync quarters:
        sync_quarters.each do |quarter|
            ce_courses =  GivepulseCourse.find_by(term: quarter.abbrev)

            if ce_courses.blank?
                puts "No courses found for #{quarter.abbrev}"
            else
                puts "Found courses: #{ce_courses.collect(&:crn).join(', ')}"

                ce_courses.each do |gp_course|
                    gp_course.add_students
                    puts "Sucessfully synced #{gp_course.crn} #{gp_course.course_students.size} students."
                end
            end
        end

    end
