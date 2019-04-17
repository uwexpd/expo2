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
          @current_person = current_user.person
          @my_appointments = @current_person.appointments.today + @current_person.appointments.yesterday + @current_person.appointments.tomorrow
          table_for @my_appointments do 
            column('Time') {|appointment| link_to appointment.start_time.to_s(:date_pretty), admin_appointment_path(appointment) }
            column :student            
          end
          if @my_appointments.blank?
            div id: 'create_appointment' do
              link_to 'No current appointments. Create an appointment.', new_admin_appointment_path
            end
          end
        end
      end
      column max_width: '33%' do
        panel "Student Search" do
          para ''
          para ''
        end

        if current_user.has_role?(:vicarious_login)
          panel "Vicarious Login" do
            header_action link_to('Open to Login', {remote: true}, data: { link_toggle: "#vicarious_login"})
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
        panel 'Offerings by Unit' do
          @offering_by_unit = Offering.group(:unit).count.map{|k,v| [k.name, v]}
          render partial: 'charts/offering_by_unit', locals: { offering_by_unit: @offering_by_unit }
        end
      end
    end
    
  end # content
  
end
