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
          panel "Recent Scholarships" do
            table_for Scholarship.order("created_at desc").limit(5) do
              column("Status")     {|scholarship| status_tag(scholarship.is_active? ? 'active' : 'inactive') }
              column("Scholarship"){|scholarship| link_to(scholarship.title, admin_scholarship_path(scholarship)) }
              column("Created at") {|scholarship| scholarship.created_at.to_date }                
            end
          end
        end

        column do
          div id: "welcome_dashboard" do
            panel "Welcome to EXPO Admin" do
                para "More functions are on the way!"
            end
          end
        end
    
    end # columns
    
  end # content
end
