ActiveAdmin.register OfferingPage, as: 'pages' do
	belongs_to :offering
	batch_action :destroy, false
	menu false
	config.sort_order = 'ordering_asc'
	config.filters = false
	reorderable

	permit_params :title, :description, :introduction, :hide_in_admin_view, :hide_in_reviewer_view, :ordering, :invisible

	member_action :form_builder, :method => :get do
		# TODO: We could implment a form_builder
	end

	index as: :reorderable_table do
		column ('Order') {|page| page.ordering}
		column ('Title') {|page| link_to page.title, admin_offering_page_path(offering, page)}
	    column ('Questions') {|page| link_to page.questions.count, admin_offering_page_questions_path(offering, page)}
	    column ('Question Titles') {|page| page.questions.collect{|q| link_to q.short_question_title, edit_admin_offering_page_question_path(offering, page, q)}}
	    actions
	end

	show do
	  attributes_table do
	    row :title
        row :description
        row ('Introduction'){|page| raw page.introduction }
        row :hide_in_admin_view
        row :hide_in_reviewer_view
        row :invisible
	  end
	  panel '' do
		div :class => 'content-block' do
			em '*', class: 'required'
			span ' = required field'
			reorderable_table_for pages.questions.order('ordering ASC'), id: 'show_table_offering_questions' do
              # column ('#') {|question| question.ordering }
              column ('Questions') {|question| (link_to question.short_question_title,admin_offering_page_question_path(offering, pages, question)) + (content_tag(:em, " *", :class => 'required') if question.required?) }
              column ('Type'){|question| question.display_as.titleize}
              column ('Data Storage'){|question|
					if OfferingQuestion::QUESTION_TYPES_NOT_REQUIRING_ATTRIBUTE_TO_UPDATE.include?(question.display_as)
						content_tag(:span, "n/a", :class => 'light')
			        elsif question.dynamic_answer?
						status_tag "dynamic answer", class: 'small'
					else
						content_tag(:code, (question.full_attribute_name))
					end}
			  column ('Functions'){|question|
						span link_to '<span class="material-icons">visibility</span>'.html_safe, admin_offering_page_question_path(offering, pages, question), class: 'action_icon'
						span link_to '<span class="material-icons">edit</span>'.html_safe, edit_admin_offering_page_question_path(offering, pages, question), class: 'action_icon'
						span link_to '<span class="material-icons">delete</span>'.html_safe, admin_offering_page_question_path(offering, pages, question), method: :delete, data: { confirm:'Are you sure?', :remote => true}, class: 'delete action_icon'
			         }
			end
			div link_to '<span class="material-icons md-20">add</span>Add New Question'.html_safe, new_admin_offering_page_question_path(offering, pages), class: 'button add'
		end
	  end
	end

	sidebar "Offering Settings", only: :index do
		render "admin/offerings/sidebar/settings", { offering: offering }
  	end
	# sidebar "Form Builder", only: [:show, :edit] do
 #  	   link_to 'Use Form Builder', form_builder_admin_offering_page_path, class: 'information'
 #  	end
	sidebar "Pages", only: [:show, :edit] do
        render "admin/offerings/pages/pages", { offering: offering, offering_page: pages }
  	end

	form do |f|
	  f.semantic_errors *f.object.errors.keys
	  ordering = offering.pages.size==0 ? [1] : (1..offering.pages.collect(&:ordering).compact.max()+1).to_a.reverse rescue [1]

	  f.inputs do
	    f.input :title, as: :string
	    f.input :ordering, label: 'Order', as: :select, collection: ordering, include_blank: false
	    #
	    f.input :description, as: :text, input_html: { rows: 3, style: 'width: 100%'  }
	    f.input :introduction, as: :text, input_html: { :class => "tinymce", rows: 8, style: 'width: 100%'  }
	    f.input :hide_in_admin_view, label: 'Hide this page when viewing an application in admin view. (This also hides this page from reviewers)'
	    f.input :hide_in_reviewer_view, label: 'Hide this page when a reviewer is viewing an application'
	    f.input :invisible, label: 'Hide this page by default unless toggled by question option with next_page'
	  end
	  f.actions
	end


end	