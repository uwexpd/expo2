ActiveAdmin.register OfferingQuestionOption, as: 'options' do
	batch_action :destroy, false
	menu false	
	config.filters = false

	permit_params :title, :value, :associate_question_id, :ordering, :next_page_id

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

	show do 
	  attributes_table do
	  	row :offering_question	  	
	  	row :title
	  	row :value
	  	row :associate_question
	  	row :next_page
	  	row :ordering
	  end	
	end

	form do |f|
	  offering = controller.instance_variable_get(:@offering)
	  page = controller.instance_variable_get(:@page)
	  f.semantic_errors *f.object.errors.keys
	  f.inputs do
	    f.input :title, hint: 'The text displayed to the user.'
	    f.input :value, hint: 'The value stored in the database. Leave this blank to just use the title as the value.'
	    f.input :associate_question, label:'Toogle Question', as: :select, collection: page.questions.pluck(:question, :id), include_blank: true, hint: 'Radio button that toggles with another question. Please input the question you would like to toogle.', input_html: { style: "width: 100%;" }
	    f.input :next_page, label: 'Toggle Next Page', as: :select, collection: offering.pages.pluck(:title, :id), include_blank: true
	    f.input :ordering
	  end
	  f.actions
	end

end