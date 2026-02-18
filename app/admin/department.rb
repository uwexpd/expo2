# app/admin/departments.rb
ActiveAdmin.register Department do
  batch_action :destroy, false  
  config.sort_order  = 'dept_full_nm_asc'
  config.per_page    = [30, 50, 100, 200]

  menu parent: 'Groups', priority: 15, label: "<i class='mi padding_right'>domain</i> Departments".html_safe

  actions :index, :show

  index do
    column :dept_code
    column "Name", sortable: :dept_full_nm do |d|
      d.dept_full_nm&.strip&.titleize
    end
    column "Abbreviation", sortable: :dept_abbr do |d|
      d.dept_abbr&.strip
    end    
    column "College" do |d|
      d.college&.name
    end
    actions
  end

  show do
    attributes_table do
      row :dept_code
      row("Department Name") do |d|
        d.dept_full_nm&.strip&.titleize
      end
      row("Abbreviation") do |d|
        d.dept_abbr&.strip
      end
      row("Email") do |d|
        d.dept_email_addr&.strip
      end
      row("College") do |d|
        d.college&.name
      end

      row("Chair Name")  { |d| d.chair_name }
      row("Chair Title") { |d| d.chair_title }
      row("Chair Email") { |d| d.chair_email }

    end

    panel "Majors" do
      table_for department.majors do
        column :major_code
        column :major_name
      end
    end
  end

  filter :dept_code
  filter :dept_full_nm_cont, label: "Department Name"
  filter :dept_abbr_cont, label: "Abbreviation"  
  # filter :college, as: :select, collection: -> { College.order(:name).pluck(:name, :id) } wait for rails 6
end