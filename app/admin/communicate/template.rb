ActiveAdmin.register TextTemplate, as: 'template'  do
  batch_action :destroy, false
  config.sort_order = 'created_at_desc'
  config.per_page = [30, 50, 100, 200]
  menu parent: 'Modules', label: 'Email Template', :priority => 35

  permit_params :body, :name, :subject, :from

  index do
    column ('Name') {|template| link_to template.title, admin_template_path(template) }
    column ('Subject') {|template| template.subject if template.subject}
    actions
  end

  show do
    attributes_table do
       row ('To') {|template| "(recipient's name)" }
       row :from
       row :subject
       row ('body'){|template| simple_format(template.body.to_s) }
   	end
  end

  form do |f|
    semantic_errors *f.object.errors.keys
    f.inputs do
    	f.input :name, label: 'Title', :input_html => { :style => 'width:65%;' }
    	f.input :from, :input_html => { :style => 'width:65%;' }
    	f.input :subject, :input_html => { :style => 'width:65%;' }
    	# TODO Add a switch to swith tinymice editor and plain text input
    	# https://materializecss.com/switches.html
    	# div 'HTML Editor', class: 'switch' do |d|
    	# 	d.label do |l|
    	# 		l.input :boolean
    	# 		l.span 'on', class: 'lever'
    	# 	end
    	# end  
    	f.input :body, :input_html => { :style => 'width:80%;', :rows => 25 }
    end
    # script do
    #   raw '$(document).ready(function($) {console.log("insert page initialization code here");})'
    # end
    f.actions
  end  

  filter :name, as: :string
  filter :subject, as: :string
end
