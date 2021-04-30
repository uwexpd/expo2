ActiveAdmin.register OfferingQuestion, as: 'questions'  do
	batch_action :destroy, false
	menu false
	config.filters = false


	controller do
		nested_belongs_to :offering, :page
		before_action :fetch_page

		def destroy
			@question = @page.questions.find(params[:id])
			@question.destroy

		    respond_to do |format|
		      format.html { redirect_to(admin_offering_page_questions_path(@offering, @page)) }
		      format.js
			end
		end

		protected

		def fetch_page
			@offering = Offering.find params[:offering_id]
			@page = @offering.pages.find params[:page_id]
			# session[:breadcrumbs].add "#{@page.title}", offering_page_path(@offering, @page)
		end
	end

	show do
	  attributes_table do
        row :question
        row :offering_page_id
	  end
	end

	sidebar "Questions", only: [:show, :edit] do
		render "questions", { offering_question: questions}
	end

	form do |f|
	  f.semantic_errors *f.object.errors.keys
	  page = offering.pages.find params[:page_id]
      tabs do
        tab 'Question Details' do
		  f.inputs do
		    f.input :offering_page_id, required: true, as: :select, collection: offering.pages
		    f.input :question, as: :text, required: true, input_html: {cols:50, rows: 3, style: 'width: 100%'}
		    div 'Specify the "question" here. This could be very short or quite long; there are no restrictions on length.', class: 'caption'
		    f.input :short_title, input_html: {style: 'width: 50%'}
		    div 'EXPO will use the short title to refer to this question in the admin area,
			and on the Application Review page for students and reviewers. Leave blank to use the
			full question title for this purpose instead.', class: 'caption'
			f.input :ordering, label: 'Order', as: :select, collection:  (1..page.questions.size+1).to_a, include_blank: false
			div 'You can also rearrange questions when viewing the page details.', class: 'caption'
			f.input :display_as, label: 'Type', required: true, as: :select, collection: OfferingQuestion.display_as_options.collect{|o| [o[:title], o[:name]]}, include_blank: true
			div 'Determines how this question will be displayed to the student.', class: 'caption'
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
			f.input :attribute_to_update, label: 'Field name', input_html: { style: 'width:50%;font-family: "Courier New", Courier, mono;'}
		  end
		end
		tab 'Validation' do
	        f.inputs do

	        end
	    end
	  end
	  f.actions
	end

end	