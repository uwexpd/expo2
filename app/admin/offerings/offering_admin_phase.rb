ActiveAdmin.register OfferingAdminPhase, as: 'phases' do
	belongs_to :offering
	batch_action :destroy, false
	config.filters = false
	config.sort_order = 'sequence_asc'
	reorderable
	
	permit_params :name, :display_as, :sequence, :notes, :show_progress_completion, :in_progress_application_status_types
	
	index as: :reorderable_table, title: 'Admin Phases & Tasks' do		
	  column ('#') {|phase| phase.sequence }
      column ('Name') {|phase| link_to phase.name, admin_offering_phase_path(offering, phase) }
      column ('Tasks') {|phase| link_to pluralize(phase.tasks.size, "task"), admin_offering_phase_tasks_path(offering, phase) }      
      actions
    end

    sidebar "Offering Settings", only: :index do
		render "admin/offerings/sidebar/settings", { offering: offering }
  	end

  	sidebar "Phases", only: [:show, :edit] do
		render "admin/offerings/phases/phases", { offering: offering, offering_phase: phases }
  	end

  	show title: proc { resource.name } do
  	  attributes_table do
		row :name
		row :display_as
		row :sequence
		row (:notes){|phase| raw(phase.notes)}
      end
	  panel '' do
		div :class => 'content-block' do
			tasks = phases.tasks.order('sequence')
			reorderable_table_for tasks, id: 'show_table_offering_tasks' do
			  column ('#') {|task| (tasks.index(task))+1 }
              column ('Tasks') {|task| link_to task.title, admin_offering_phase_task_path(offering, phases, task) } 
              column ('Display As'){|task| task.read_attribute(:display_as).titleize rescue "<span class='light'>(default)</span>".html_safe }
              column ('Extra Fields') {|task| link_to task.extra_fields.size, admin_offering_phase_task_extra_fields_path(offering, phases, task)}
			  column ('Functions'){|task|
				span link_to '<span class="material-icons">visibility</span>'.html_safe, admin_offering_phase_task_path(offering, phases, task), class: 'action_icon'
				span link_to '<span class="material-icons">edit</span>'.html_safe, edit_admin_offering_phase_task_path(offering, phases, task), class: 'action_icon'
				span link_to '<span class="material-icons">delete</span>'.html_safe, admin_offering_phase_task_path(offering, phases, task), method: :delete, data: { confirm:'Are you sure?', :remote => true}, class: 'delete action_icon'
	            }
			end			
			div link_to '<span class="material-icons md-20">add</span>Add New Task'.html_safe, new_admin_offering_phase_task_path(offering, phases), class: 'button add'
		end
	  end	  
  	end

  	form do |f|
	  f.semantic_errors *f.object.errors.keys
	  f.inputs do
	    f.input :name, input_html: {style: 'width: 50%'} 
	    f.input :sequence, input_html: {style: 'width: 5rem;'}
	    f.input :notes, input_html: { class: 'tinymce' ,rows: 4, style: 'width: 100%'}
	    div 'Options', class: 'label'	    
	    f.input :show_progress_completion, as: :boolean, 
	    # input_html: { data: { if: 'not_checked', then: 'fade', target: '#relevant_field_for_show_progress_completion'} }, 
	    hint: 'Use columns to show the completion of progress when displaying this phase. If unchecked, then just task names are displayed.'
	    div id: 'relevant_field_for_show_progress_completion' do
		    f.input :in_progress_application_status_types, label: 'Action Required Statuses', input_html: { rows: 4, style: 'width: 40%; font-family: Consolas,Monaco,Lucida Console, Mono,DejaVu Sans Mono,Courier New;'}
		    f.input :success_application_status_types, label: 'Moving Forward Statuses', input_html: { rows: 4, style: 'width: 40%; font-family: Consolas,Monaco,Lucida Console, Mono,DejaVu Sans Mono,Courier New;'}
		    f.input :failure_application_status_types, label: 'Stopping Here Statuses', input_html: { rows: 4, style: 'width: 40%; font-family: Consolas,Monaco,Lucida Console, Mono,DejaVu Sans Mono,Courier New;'}
		end
	  end
	  f.actions
	end

end