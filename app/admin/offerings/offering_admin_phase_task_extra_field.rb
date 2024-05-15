ActiveAdmin.register OfferingAdminPhaseTaskExtraField, as: 'extra_fields'  do	
	batch_action :destroy, false
	menu false
	config.filters = false

	permit_params :title, :display_method

	breadcrumb do
  	[
  		link_to('Expo', root_path),
  		link_to('Offerings',admin_offerings_path ),
  		link_to("#{controller.instance_variable_get(:@offering).title}", "/expo/admin/offerings/#{controller.instance_variable_get(:@offering).id}" ),
  		link_to('Phases', admin_offering_phases_path),  		
  		link_to("#{controller.instance_variable_get(:@phase).name}", "/expo/admin/offerings/#{controller.instance_variable_get(:@offering).id}/phases/#{controller.instance_variable_get(:@phase).id}" ),
  		link_to('Tasks', admin_offering_phase_tasks_path),
  		link_to("#{controller.instance_variable_get(:@phase).name}", "/expo/admin/offerings/#{controller.instance_variable_get(:@offering).id}/phases/#{controller.instance_variable_get(:@phase).id}/tasks/#{controller.instance_variable_get(:@task).id}" )
  	 ]
  end

	controller do
		nested_belongs_to :offering, :phase, :task
		before_action :fetch_task

		def destroy
			@extra_field = @task.extra_fields.find(params[:id])
			@extra_field.destroy

		    respond_to do |format|		    	
		      format.html { redirect_to edit_admin_offering_phase_task_path(@offering, @phase, @task, :anchor => "extra-fields-#{@task.extra_fields.size}") }
		      format.js { render js: "$('.delete').bind('ajax:success', function() {$(this).closest('tr').fadeOut();});"}
			end
		end

		protected
  
	    def fetch_task
	      @offering = Offering.find params[:offering_id]
		  @phase = @offering.phases.find params[:phase_id]
	      @task = @phase.tasks.find params[:task_id]
	    end
	end

	index do
	  column ('Title') {|extra_field| link_to extra_field.title, admin_offering_phase_task_extra_field_path(offering, phase, task, extra_field) }
	  column :display_method, input_html: {style: 'font-family: Consolas,Monaco,Lucida Console, Mono,DejaVu Sans Mono,Courier New;'}
	  actions
	end

	sidebar "Tasks & Extra Fields" do
	  render "admin/offerings/phases/tasks/extra_fields", { phase: phase, phase_task: task, extra_field: extra_fields }
  	end

	show do
      attributes_table do
        row :title
        row :display_method, input_html: {style: 'font-family: Consolas,Monaco,Lucida Console, Mono,DejaVu Sans Mono,Courier New;'}
	  end
	end

	form do |f|
	  f.semantic_errors *f.object.errors.keys
	  f.inputs do
	  	f.input :title
	  	f.input :display_method, input_html: { style: 'width:50%; font-family: Consolas,Monaco,Lucida Console, Mono,DejaVu Sans Mono,Courier New;'}
	  end
	  actions
	end


end
