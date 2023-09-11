ActiveAdmin.register OfferingQuestionOption, as: 'options' do
	batch_action :destroy, false
	menu false	
	config.filters = false

	permit_params :title, :value, :associate_question_id

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
			@option = @question.options.find(params[:id])
			@option.destroy

		    respond_to do |format|		    	
		      format.html { redirect_to edit_admin_offering_page_question_path(offering, @page, @question, :anchor => 'response-options') }
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
		column :title
		column :value		
		actions
	end

	form do |f|
	  f.semantic_errors *f.object.errors.keys
	  f.inputs do
	    f.input :title, hint: 'The text displayed to the user.'
	    f.input :value, hint: 'The value stored in the database. Leave this blank to just use the title as the value.'
	    f.input :associate_question_id, label:'Toogle Question ID', hint: 'Radio button that toggles with another question. Please input the question ID you would like to toogle.'
	  end
	  f.actions
	end

end