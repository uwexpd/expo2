ActiveAdmin.register CommitteeQuarter do
	belongs_to :committee
	includes :quarter
	config.filters = false
	batch_action :destroy, false
	actions :all, :except => [:destroy]

	permit_params :quarter_id, :alternate_title, :comments_prompt_text

	index do
	  column ('Quarter'){|cq| link_to cq.title, admin_committee_committee_quarter_path(committee, cq)}
	  column ('Active Members'){|cq| cq.committee_member_quarters.active.size }
	  actions
	end

	batch_action :send_mass_emails do |ids|
    memebers = []
    CommitteeMemberQuarter.where(id: ids).each do |memeber|
      memebers << memeber if memeber
    end
    redirect_to admin_email_write_path("select[#{memebers.first.class.to_s}]": memebers)
  end

	show do
	  active_quarter_members = committee_quarter.committee_member_quarters.active
		div class: 'panel panel_contents content-block', id: 'committee_quarter' do
		  h2 committee_quarter.title do
		    span("» #{pluralize(active_quarter_members.size, 'active member')}", class: 'smaller gray')
		  end
		  form action: batch_action_admin_committee_committee_quarters_path, method: :post do
        input type: :hidden, name: :authenticity_token, value: form_authenticity_token
        input type: :hidden, name: :batch_action, value: "send_mass_emails"
			  table_for active_quarter_members do
			  	  column "#{check_box_tag "select_all", nil, false, id: "select-all"}".html_safe do |item|
              check_box_tag "collection_selection[]", item.id, false, class: "batch-checkbox"
            end
		        column ('Committee Member') {|member| link_to member.committee_member.fullname, admin_committee_member_path(committee, member.committee_member) rescue "(error)" }
		        column ('Type') {|member| member.committee_member.committee_member_type.name rescue "<span class=light>None</span>".html_safe }
		        column ('Department') {|member| member.committee_member.department rescue 'Error'}
		        column ('Expertise') {|member| member.committee_member.expertise.truncate(50) rescue nil}
		        column ('Comment') do |member|
	              span(member.comment, class: 'light smaller')
		        end
		        column ('Last Response') {|member| relative_timestamp(member.committee_member.last_user_response_at, :date_only => true, :empty_string => "Never") rescue nil}		      
		    end
		    div class: "buttons" do
          button "<i class='mi'>email</i> Send Mass E-mail With Selected".html_safe, type: :submit
        end
		  end
		end
	end

	form do |f|
      semantic_errors *f.object.errors.keys
      f.inputs do
        f.input :quarter_id, as: :select, collection: Quarter.all.select{|q|q.year > 2007}.sort_by(&:year).map{|q| [q.title, q.id]}, selected: Quarter.current_quarter.id
        f.input :alternate_title, hint: 'If this quarter would be better represented by a different title, enter it here. Leave blank to simply use the quarter title.'
        f.input :comments_prompt_text, hint: 'This text appears before the comments entry box for a specific quarter. Leave blank for the default "Comments?"'
      end
      f.actions
  end

end