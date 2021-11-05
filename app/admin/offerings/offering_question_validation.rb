ActiveAdmin.register OfferingQuestionValidation, as: 'validations' do
	batch_action :destroy, false
	menu false	
	config.filters = false

	permit_params :type, :custom_error_text

	breadcrumb do
  	[
  		link_to('Expo', root_path),
  		link_to('Offerings',admin_offerings_path ),
  		link_to("#{controller.instance_variable_get(:@offering).title}", "/expo/admin/offerings/#{controller.instance_variable_get(:@offering).id}" ),
  		link_to('Pages', admin_offering_pages_path),
  		link_to("#{controller.instance_variable_get(:@page).title}", "/expo/admin/offerings/#{controller.instance_variable_get(:@offering).id}/pages/#{controller.instance_variable_get(:@page).id}" ),
  		link_to('Tasks', admin_offering_page_questions_path),
  		link_to("#{controller.instance_variable_get(:@question).short_question_title}", "/expo/admin/offerings/#{controller.instance_variable_get(:@offering).id}/pages/#{controller.instance_variable_get(:@page).id}/questions/#{controller.instance_variable_get(:@question).id}" )
  	 ]
	end

	controller do
		nested_belongs_to :offering, :page, :question
		before_action :fetch_question

		def destroy
			@validation = @question.validations.find(params[:id])
			@validation.destroy

		    respond_to do |format|		    	
		      format.html { redirect_to edit_admin_offering_page_question_path(offering, @page, @question, :anchor => 'validation') }
		      format.js { render js: "$('.delete').bind('ajax:success', function() {$(this).closest('tr').fadeOut();});"}
			end
		end

		protected
  
	    def fetch_question
	      @offering = Offering.find params[:offering_id]
		  @page = @offering.pages.find params[:page_id]
	      @question = @page.questions.find params[:question_id]
	    end
	end

	index do
		# column :type
		column ('Type') {|validation| link_to validation.class.to_s.titleize, edit_admin_offering_page_question_validation_path(offering, validation.offering_question.offering_page, validation.offering_question, validation)}
		column :error_message		
		actions
	end

	form do |f|
	  f.semantic_errors *f.object.errors.keys
	  f.inputs do
	    f.input :type, required: true, as: :select, collection: %w(MustBeWholeNumberValidation
								MustAnswerYesValidation
								MustBeValidPhoneNumberValidation
								MustBeValidEmailAddressValidation
								MustBeNumberValidation
								MustBeValidNetidValidation).sort, prompt: true
	    f.input :custom_error_text, label: 'Custom Error Text', as: :text, input_html: {cols:50, rows: 3, style: 'width: 100%'}
	  end
	  f.actions
	end

end