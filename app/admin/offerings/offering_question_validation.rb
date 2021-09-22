ActiveAdmin.register OfferingQuestionValidation, as: 'validations' do
	batch_action :destroy, false
	menu false	
	config.filters = false

	permit_params :type, :custom_error_text

	controller do
		nested_belongs_to :offering, :page, :question
		before_action :fetch_question

		def destroy
			@validation = @question.validations.find(params[:id])
			@validation.destroy

		    respond_to do |format|		    	
		      format.html { redirect_to edit_admin_offering_page_question_path(offering, @page, @question, :anchor => 'validation') }
		      format.js
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