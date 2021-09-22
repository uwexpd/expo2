ActiveAdmin.register OfferingQuestionOption, as: 'options' do
	batch_action :destroy, false
	menu false	
	config.filters = false

	permit_params :title, :value

	controller do
		nested_belongs_to :offering, :page, :question
		before_action :fetch_question

		def destroy
			@option = @question.options.find(params[:id])
			@option.destroy

		    respond_to do |format|		    	
		      format.html { redirect_to edit_admin_offering_page_question_path(offering, @page, @question, :anchor => 'response-options') }
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
		column :title
		column :value		
		actions
	end

	form do |f|
	  f.semantic_errors *f.object.errors.keys
	  f.inputs do
	    f.input :title
	    div 'The text displayed to the user.', class: 'caption'
	    f.input :value
	    div 'The value stored in the database. Leave this blank to just use the title as the value.', class: 'caption'
	  end
	  f.actions
	end

end