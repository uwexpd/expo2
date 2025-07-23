desc "Daily sync Community Engaged course roster to UW GivePuse."
    task :givepulse_roster_sync => :environment do
        start_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
        puts "=== #{start_time} : START givepulse_roster_sync ==="
        
        sync_quarters = [Quarter.current_quarter, Quarter.current_quarter.next]
    	
        puts "#{sync_quarters.collect(&:title)} Course roster sync starts..."
        
        # Get GP CE courses with sync quarters:
        sync_quarters.each do |quarter|
            ce_courses =  GivepulseCourse.where(term: quarter.title)

            if ce_courses.blank?
                puts "No courses found for #{quarter.title}"
            else
                puts "Found courses: #{ce_courses.collect(&:crn).join(', ')} in #{quarter.title}"

                ce_courses.each do |gp_course|
                    gp_course.sync_course_students
                    puts "Sucessfully synced #{gp_course.crn} #{gp_course.course_students.size} students."
                end
            end
        end

        end_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
        puts "=== #{end_time} : END givepulse_roster_sync ==="

    end
