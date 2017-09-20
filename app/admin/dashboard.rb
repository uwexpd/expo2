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
      column min_width: '65%' do
        panel 'Current Appointments' do
          para ''
        end
      end
      column max_width: '33%' do
        panel "Student Search" do
          para ''
        end
      end
    end

    
    columns do
      column do        
          panel "Modules" do
            render 'modules'            
          end        
      end        
    end
    
    columns do
      column do
        panel "Management Tools" do
          para ''
        end
      end      
    end
    
    columns do
      column do
        panel 'Offerings by Unit' do
          @offering_by_unit = Offering.group(:unit).count.map{|k,v| [k.name, v]}
          render partial: 'charts/offering_by_unit', locals: { offering_by_unit: @offering_by_unit }
        end
      end
    end
    
      # column do
      #         panel "Recent Scholarships" do
      #           table_for Scholarship.order("created_at desc").limit(5) do
      #             column("Status")     {|scholarship| status_tag(scholarship.is_active? ? 'active' : 'inactive', class: 'small')  }
      #             column("Scholarship"){|scholarship| link_to(scholarship.title, admin_scholarship_path(scholarship)) }
      #             column("Created at") {|scholarship| scholarship.created_at.to_date }
      #           end
      #         end
      #       end  
    
  end # content
end
