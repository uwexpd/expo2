ActiveAdmin.register OfferingQuestion, as: 'questions'  do
	batch_action :destroy, false
	menu false
	config.filters = false
	config.sort_order = 'ordering_asc'
	reorderable

	permit_params :offering_page_id, :question, :short_title, :ordering, :display_as, :dynamic_answer, :model_to_update, :attribute_to_update, :required, :character_limit, :word_limit, :caption, :error_text, :help_text, :help_link_text, :width, :height, :use_mce_editor, :hide_in_reviewer_view

	# wordaround for nested_belongs_to breadcrumbs display incorrectly
	breadcrumb do
  	[
  		link_to('Expo', root_path),
  		link_to('Offerings',admin_offerings_path ),
  		link_to("#{controller.instance_variable_get(:@offering).title}", "/expo/admin/offerings/#{controller.instance_variable_get(:@offering).id}" ),
  		link_to('Pages', admin_offering_pages_path),  		
  		link_to("#{controller.instance_variable_get(:@page).title}", "/expo/admin/offerings/#{controller.instance_variable_get(:@offering).id}/pages/#{controller.instance_variable_get(:@page).id}" )
  	 ]
  end

  member_action :reorder, method: :post do  		
	    offering_question = OfferingQuestion.find(params[:id])
	    offering_question.insert_at(params[:position].to_i)
	    head :ok
  end

	controller do
		nested_belongs_to :offering, :page
		before_action :fetch_page, except: [:reorder]

		def destroy
			@question = @page.questions.find(params[:id])
			@question.destroy

		    respond_to do |format|
		      format.html { redirect_to(admin_offering_page_questions_path(@offering, @page)) }
		      format.js { render js: "$('.delete').bind('ajax:success', function() {$(this).closest('tr').fadeOut();});"}
			end
		end

		protected

		def fetch_page		
			@offering = Offering.find params[:offering_id]
			@page = @offering.pages.find params[:page_id]
		end
	end

	index as: :reorderable_table do
		column ('#') {|question| question.ordering }
    column ('Questions') {|question| (link_to question.short_question_title,admin_offering_page_question_path(offering, question.offering_page, question)) + (content_tag(:em, " *", :class => 'required') if question.required?)}
		column ('Type'){|question| question.display_as.titleize}
    column ('Data Storage') {|question|
				if OfferingQuestion::QUESTION_TYPES_NOT_REQUIRING_ATTRIBUTE_TO_UPDATE.include?(question.display_as)
					content_tag(:span, "n/a", :class => 'light')
		        elsif question.dynamic_answer?
					status_tag "dynamic answer", class: 'small'
				else
					content_tag(:code, (question.full_attribute_name))
				end}
		actions
	end

	show do
	  attributes_table do
        row :question        
        row :offering_page_id
        row :required
        row :display_as
        row :model_to_update
        row :attribute_to_update
        row :hide_in_reviewer_view        
        row :character_limit
        row :word_limit
        row :caption
        row :error_text
        row :help_text
        row :help_link_text
        row :ordering
	  end
	end
	
	sidebar "Pages", only: [:index] do
    render "admin/offerings/pages/pages", { offering: offering, offering_page: @page }
  end

	sidebar "Questions", only: [:show, :edit] do
		render "admin/offerings/pages/questions/questions", { offering_question: questions}
	end


	form do |f|
	  f.semantic_errors *f.object.errors.keys
	  page = offering.pages.find params[:page_id]
    tabs do
      tab 'Question Details' do
			  f.inputs do
			    f.input :offering_page_id, required: true, as: :select, collection: offering.pages
			    f.input :question, as: :text, required: true, input_html: {cols:50, rows: 3, style: 'width: 100%'}, hint: 'Specify the "question" here. This could be very short or quite long; there are no restrictions on length.'
			    f.input :short_title, input_html: {style: 'width: 50%'}, hint: 'EXPO will use the short title to refer to this question in the admin area, and on the Application Review page for students and reviewers. Leave blank to use the full question title for this purpose instead.'
				f.input :ordering, label: 'Order', as: :select, collection: page.questions.size==0 ? [1] : (1..page.questions.collect(&:ordering).compact.max()+1).to_a.reverse, include_blank: false, hint: 'You can also rearrange questions when viewing the page details.'
				f.input :display_as, label: 'Type', required: true, as: :select, collection: OfferingQuestion.display_as_options.collect{|o| [o[:title], o[:name]]}, include_blank: true, hint: 'Determines how this question will be displayed to the student.'
			  end
			  f.inputs 'Data Storage' do
				hr
				div "Depending on the question, you might not need to store applicants' responses in
				a predefined field in the database. This is called a <strong>\"dynamic answer\"</strong> and answers are simply stored
				in an extra table so that you can view the answer in the application details. To store the answer
				in a specific database field instead, leave this box unchecked and choose the database field to store
				the answer below. This can be necessary for data attributes that need to be queried or utilized outside
				simply viewing of the answer.".html_safe, class: 'intro'
				f.input :dynamic_answer, label: "Don't link to a specific field in the database", as: :boolean, required: true
				f.input :model_to_update, label: 'model_to_update', as: :select, collection: { 'Person' => 'person', 'Student Database' => 'person.sdb' }, :include_blank => "Application"
				f.input :attribute_to_update, label: 'Field name', input_html: { class: 'code half_width'}
			  end
		  end
		  if !f.object.new_record?
			  tab 'Validation' do
		       f.inputs 'Data Validation' do
		         hr
		         div 'Use these options to impose restrictions on the way this question is answered.', class: 'intro'
		         f.input :required, label: 'Answer is required', as: :boolean
		         f.input :character_limit, :input_html => { :style => "width:15%;" }
		         f.input :word_limit, :input_html => { :style => "width:15%;" }
		       end
		       f.inputs 'Advanced Validations' do
		       	 panel '' do
				   div :class => 'content-block' do
		       	     table_for questions.validations do
		       	 	   column ('Validation Type'){|validation| validation.class.to_s.titleize}
		       	 	   column ('Error Text'){|validation| validation.error_message}
		       	 	   column ('Functions'){|validation|					
							span link_to '<span class="material-icons">edit</span>'.html_safe, edit_admin_offering_page_question_validation_path(offering, page, questions, validation), class: 'action_icon'
							span link_to '<span class="material-icons">delete</span>'.html_safe, admin_offering_page_question_validation_path(offering, page, questions, validation), method: :delete, data: { confirm:'Are you sure?', :remote => true}, class: 'delete action_icon'}
		       	     end
		       	     div link_to '<span class="material-icons md-20">add</span>Add New Validation'.html_safe, new_admin_offering_page_question_validation_path(offering, page, questions), class: 'button add'
		       	   end
		       	 end
		       end
		    end
		    tab 'Display' do
		      f.inputs 'Question Display' do
		         hr
		         f.input :hide_in_reviewer_view, as: :boolean, hint: 'This question will NOT display in the reviewr inteface.'
		         div 'Change the way this question is displayed.', class: 'intro'
		         f.input :caption, as: :text, input_html: {cols:50, rows: 3, style: 'width: 100%'}, hint: 'This text is shown below the question and can provide additional guidance.'
		         f.input :error_text, as: :text, input_html: {cols:50, rows: 2, style: 'width: 100%'}, hint: "All validations provide their own custom error text but you can use this to override the default error message when a question hasn't been answered properly."
		         f.input :help_text, as: :text, input_html: {cols:50, rows: 3, style: 'width: 100%'}, hint: 'If you provide help text, a link will be provided that allows an applicant to view more in-depth help text for this question.'
		         f.input :help_link_text, hint: "Normally a little help icon is used as the link, but if you'd like to provide specific text for the link itself, specify it here."
		         div 'Text Area Inputs', class: 'label'		         
		         f.input :width, label: 'Columns', input_html: { style: "width:10%;" }
		         f.input :height, label: 'Rows', input_html: { style: "width:10%;" }, hint: 'Leave these fields blank to use the default text box size.'
		         f.input :use_mce_editor, as: :boolean, hint: 'Provide a text editor that includes formatting support for rich text editing (bold, italic, etc.). If this is unchecked, applicants will simply see a standard text box that only accepts plain text.'
		      end
		    end
		    tab 'Response Options' do
		    	f.inputs 'Response Options' do
		    	  hr
		    	  div 'Specify the options that the applicant can choose from.', class: 'intro'
				  panel '' do
				    div :class => 'content-block' do
		       	  table_for questions.options do
		       	 	   column :title	       	 	   
		       	 	   column :value	       	 	   
		       	 	   column ('Functions'){|option|					
										span link_to '<span class="material-icons">edit</span>'.html_safe, edit_admin_offering_page_question_option_path(offering, page, questions, option), class: 'action_icon'
										span link_to '<span class="material-icons">delete</span>'.html_safe, admin_offering_page_question_option_path(offering, page, questions, option), method: :delete, data: { confirm:'Are you sure?', :remote => true}, class: 'delete action_icon'}
		       	  end
		       	  div link_to '<span class="material-icons md-20">add</span>Add New Option'.html_safe, new_admin_offering_page_question_option_path(offering, page, questions), class: 'button add'
		        end
		       	end	    		
		    	end
		    end
		  end
	  end
	  f.actions
	end

end	