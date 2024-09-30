ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do
    # div class: "blank_slate_container", id: "dashboard_default_message" do
    #       span class: "blank_slate" do
    #         span I18n.t("active_admin.dashboard_welcome.welcome")
    #         small I18n.t("active_admin.dashboard_welcome.call_to_action")
    #       end
    #     end
 
 
    columns do
      column do        
          panel "Modules" do
            render 'modules'            
          end        
      end        
    end
    
    columns do
      column min_width: '65%' do
        panel 'Current Appointments' do
          header_action link_to "<i class='mi'>event_available</i> Create".html_safe, new_admin_appointment_path
          @current_person = current_user.person
          @my_appointments = @current_person.appointments.today + @current_person.appointments.yesterday + @current_person.appointments.tomorrow
          table_for @my_appointments do 
            column('Time') {|appointment| link_to "<i class='mi'>today</i> ".html_safe+appointment.start_time.to_s(:date_at_time12), admin_appointment_path(appointment) }
            column :student
            column ('Checked-in') {|appointment| status_tag appointment.checked_in?, class: 'green'}
          end
          if @my_appointments.blank?
            div id: 'create_appointment' do
              link_to 'No current appointments. Create an appointment.', new_admin_appointment_path
            end
          end
        end
      end
      column max_width: '33%' do
        # panel "Student Search" do
        #   para ''
        #   para ''
        # end

        if current_user.has_role?(:vicarious_login)
          panel "Vicarious Login" do
            header_action link_to("<i class='mi'>unfold_more</i> Open to Login".html_safe, '#', data: { link_toggle: "#admin_vicarious_login"})
            render partial: 'admin/base/vicarious_login'
          end
        end
      end
    end
        
    # columns do
    #       column do
    #         panel "Management Tools" do
    #           para ''
    #         end
    #       end      
    #     end
    
    columns do
      column do
        panel 'Total Applications by Unit' do
          @app_by_unit = ApplicationForOffering.joins(offering: :unit).group('units.name').count.map { |unit_name, count| [unit_name, count] }
          #@offering_by_unit = Offering.group(:unit).count.map{|k,v| [k.name, v]}
          render partial: 'charts/app_by_unit', locals: { app_by_unit: @app_by_unit }
        end
      end
    end
    
    columns do
      column do

        records = ActiveRecord::Base.connection.execute("
          SELECT TABLE_NAME, TABLE_ROWS
          FROM INFORMATION_SCHEMA.TABLES
          WHERE TABLE_SCHEMA = '#{Rails.configuration.database_configuration[Rails.env]['database']}' AND
          TABLE_NAME in ('users','people','appointments','service_learning_placements','events','application_for_offerings', 'application_mentors')
          order by TABLE_ROWS DESC;")

        all_models_count = records.collect{ |row| [row[0], row[1].to_i]}
        
        max = all_models_count.first[1].to_f
        percent = 100.00/max

        panel "Database Records" do
          recs = ''
          all_models_count.each do |model_name, count|
            bar_size = percent*count
            bar_size = 2 if bar_size < 2 and bar_size > 0
            
            recs << "<div width='100px' class='intro'>"
            recs << link_to("#{model_name.tableize.titleize} - #{count}", "/admin/#{model_name.tableize}") rescue nil
            recs << "<div class=\"progress progress-info\">"
            recs << "<div class=\"bar\" style=\"width: #{bar_size}%\">"
            recs << "</div>"
            recs << "</div>"
            recs << "</div>"
          end
          recs.html_safe
        end
      end
    end

  end # content
  
end
