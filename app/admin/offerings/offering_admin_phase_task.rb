ActiveAdmin.register OfferingAdminPhaseTask, as: 'tasks' do	
	batch_action :destroy, false
	menu false
	config.filters = false
	config.sort_order = 'sequence_asc'

	permit_params :title, :display_as, :sequence, :notes, :progress_column_title, :context, :show_for_in_progress, :show_for_success, :show_for_failure, :completion_criteria, :progress_display_criteria, :show_for_context_object_tasks, :context_object_completion_criteria, :context_object_progress_display_criteria, :application_status_types, :new_application_status_type, :email_templates, :applicant_list_criteria, :reviewer_list_criteria, :detail_text, :url, :show_history, :complete

	breadcrumb do
  	[
  		link_to('Expo', root_path),
  		link_to('Offerings',admin_offerings_path ),
  		link_to("#{controller.instance_variable_get(:@offering).title}", "/expo/admin/offerings/#{controller.instance_variable_get(:@offering).id}" ),
  		link_to('Phases', admin_offering_phases_path),  		
  		link_to("#{controller.instance_variable_get(:@phase).name}", "/expo/admin/offerings/#{controller.instance_variable_get(:@offering).id}/phases/#{controller.instance_variable_get(:@phase).id}" )
  	 ]
  end

	controller do
    	nested_belongs_to :offering, :phase
    	before_action :fetch_phase

		def destroy
			@task = @phase.tasks.find(params[:id])
			@task.destroy

		    respond_to do |format|
		      format.html {redirect_to(admin_offering_phase_path(@offering, @phase))}
		      format.js { render js: "$('.delete').bind('ajax:success', function() {$(this).closest('tr').fadeOut();});"}
			end
		end

		protected

		def fetch_phase
			@offering = Offering.find params[:offering_id]
			@phase = @offering.phases.find params[:phase_id]			
		end
  	end

  	sidebar "Phase Tasks", only: [:index] do
		render "admin/offerings/phases/phases", { offering: offering, offering_phase: phase }
  	end
  	sidebar "Tasks", only: [:show, :edit] do
		render "admin/offerings/phases/tasks/tasks", { phase: phase, phase_task: tasks }
  	end
	
	index do
	  tasks = phase.tasks
	  column ('#') {|task| (tasks.index(task))+1 } 
      column ('Name') {|task| link_to task.title, admin_offering_phase_task_path(offering, phase, task) }
      column ('Display As'){|task| task.read_attribute(:display_as).titleize rescue "<span class='light'>(default)</span>".html_safe }
      column ('Extra Fields') {|task| link_to task.extra_fields.size, admin_offering_phase_task_extra_fields_path(offering, phase, task)}
      actions
    end

	show do
	  attributes_table do
		  row :title
		  row :sequence
		  row (:display_as) {|task| task.display_as.titleize }
		  row (:notes){|task| raw(task.notes)}
		  row :show_history
		  row ('statues'){|task| task.application_status_types || "-" }
		  row ('new status'){|task| task.new_application_status_type.try(:html_safe) || "-" }
		  row (:email_templates){|task| task.email_templates.try(:html_safe) || "-" }
		  row ('applicant criteria'){|task| task.applicant_list_criteria  || "-" }
		  row ('reviewer criteria'){|task| task.reviewer_list_criteria  || "-" }
		  row :detail_text
		  row :url
	  end
	end

	form do |f|
	  f.semantic_errors *f.object.errors.keys
	  tabs do
      	tab 'Display Options' do 
		  f.inputs do
		    f.input :title
		    f.input :sequence, input_html: {style: 'width: 10%'}
		    f.input :display_as, as: :select, collection: OfferingAdminPhaseTask.display_as_options.collect{|o| [o[:title], o[:name]]}.sort, include_blank: true
		    # TODO: add dynamic fields controll
		    # , input_html: { data: { eq: 'applicant_list', then: 'slide', target: '#relevant_field_for_application_status_types'} }
		    f.input :show_history, hint: "Show applicants in the list greyed out after you\'ve completed the task. Otherwise the applicants are removed from the list as the task is completed. Use this to be able to see the progress you've made."
				f.input :complete, hint: 'Usually the task is "completed" in the application management interface.'
				div class: 'relevant_field for_application_status_types' do
					f.input :application_status_types, label: 'Status(es)', as: :text, input_html: { rows: 3, style: 'width: 60%; font-family: Consolas,Monaco,Lucida Console, Mono,DejaVu Sans Mono,Courier New;'}
					f.input :new_application_status_type, label: 'New Status(es)', as: :text, input_html: { rows: 3, style: 'width: 60%; font-family: Consolas,Monaco,Lucida Console, Mono,DejaVu Sans Mono,Courier New;'}
				end
				f.input :email_templates, as: :text, input_html: { rows: 3, style: 'width: 60%; font-family: Consolas,Monaco,Lucida Console, Mono,DejaVu Sans Mono,Courier New;'}, class: 'relevant_field for_email_templates'
				div class: 'relevant_field for_reviewer_list_criteria' do
					f.input :applicant_list_criteria, input_html: { rows: 3, style: 'width: 60%; font-family: Consolas,Monaco,Lucida Console, Mono,DejaVu Sans Mono,Courier New;'}
					f.input :reviewer_list_criteria, input_html: { rows: 3, style: 'width: 60%; font-family: Consolas,Monaco,Lucida Console, Mono,DejaVu Sans Mono,Courier New;'}
				end
				f.input :detail_text, as: :string, class: 'relevant_field for_detail_text'
				f.input :url, input_html: { rows: 3, style: 'font-family: Consolas,Monaco,Lucida Console, Mono,DejaVu Sans Mono,Courier New;'}, class: 'relevant_field for_url'
		  end
		end
		tab 'Notes' do
		  f.inputs do
			f.input :notes, input_html: { class: "tinymce" }
		  end
		end
		tab 'Completion Criteria' do
		  f.inputs 'Completion Criteria' do		  	
		  	hr
		  	f.input :progress_column_title, hint: "If blank, the task name will be used as the column header"
		  	f.input :context, as: :select, collection: %w(applicant mentors group_members reviewers interviewers)
		  end
		  f.inputs 'Application List Display' do
		  	hr
		  	f.input :show_for_in_progress, label: "Show for <span class='blue-background'>Action Required</span> applications in this phase".html_safe
		  	f.input :show_for_success, label: "Show for <span class='green-background'>Moving Forward</span> applications in this phase".html_safe
		  	f.input :show_for_failure, label: "Show for <span class='red-background'>Stopping Here</span> applications in this phase".html_safe
		  	f.input :completion_criteria, as: :text, input_html: { rows: 3, style: 'width: 60%; font-family: Consolas,Monaco,Lucida Console, Mono,DejaVu Sans Mono,Courier New;'}
		  	f.input :progress_display_criteria, as: :text, input_html: { rows: 3, style: 'width: 60%; font-family: Consolas,Monaco,Lucida Console, Mono,DejaVu Sans Mono,Courier New;'}
		  end
		  f.inputs 'Reviewer/Interviewer List Display' do
		  	hr
		  	f.input :show_for_context_object_tasks, label: "Show for Reviewer/Interviewer tasks in this phase"
		  	f.input :context_object_completion_criteria, label: 'Completion Criteria', input_html: { rows: 3, style: 'width: 60%; font-family: Consolas,Monaco,Lucida Console, Mono,DejaVu Sans Mono,Courier New;'}, hint: "To reference this Offering, use <code>@offering</code>.".html_safe
		  	f.input :context_object_progress_display_criteria, label: "Progress Criteria", input_html: { rows: 3, style: 'width: 60%; font-family: Consolas,Monaco,Lucida Console, Mono,DejaVu Sans Mono,Courier New;'}
		  end
		end
		tab "Extra Fields (#{tasks.extra_fields.size})" do
		  panel 'Extra Fields to Display' do
		  	div :class => 'content-block' do
              table_for tasks.extra_fields do
                column ('Title') {|extra_field| link_to extra_field.title, admin_offering_phase_task_extra_field_path(offering, phase, tasks, extra_field) }
                column :display_method, input_html: {style: 'font-family: Consolas,Monaco,Lucida Console, Mono,DejaVu Sans Mono,Courier New;'}
                column ('Functions') { |extra_field|
                	span link_to '<span class="material-icons">visibility</span>'.html_safe, admin_offering_phase_task_extra_field_path(offering, phase, tasks, extra_field), class: 'action_icon'
					span link_to '<span class="material-icons">edit</span>'.html_safe, edit_admin_offering_phase_task_extra_field_path(offering, phase, tasks, extra_field), class: 'action_icon'
					span link_to '<span class="material-icons">delete</span>'.html_safe, admin_offering_phase_task_extra_field_path(offering, phase, tasks, extra_field), method: :delete, data: { confirm:'Are you sure?', :remote => true}, class: 'delete action_icon'}
              end
              div link_to '<span class="material-icons md-20">add</span>Add New Extra Field'.html_safe, new_admin_offering_phase_task_extra_field_path(offering, phase, tasks), class: 'button add'
            end
          end
		end
	  end
	  f.actions
	end

end