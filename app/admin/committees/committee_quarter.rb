ActiveAdmin.register CommitteeQuarter do
	belongs_to :committee
	config.filters = false
	batch_action :destroy, false
	actions :all, :except => [:destroy]

	permit_params :quarter_id, :alternate_title, :comments_prompt_text

	index do
	  column ('Quarter'){|cq| link_to cq.title, admin_committee_committee_quarter_path(committee, cq)}
	  column ('Active Members'){|cq| cq.committee_member_quarters.active.size }
	  actions
	end

	show do
	  active_quarter_members = committee_quarter.committee_member_quarters.active
		div :class => 'panel panel_contents content-block' do
		  h2 committee_quarter.title do
		    span("» #{pluralize(active_quarter_members.size, 'active member')}", class: 'smaller gray')
		  end
		  table_for active_quarter_members do
	        column ('Committee Member') {|member| link_to member.committee_member.fullname, admin_committee_member_path(committee, member.committee_member) rescue "(error)" }
	        column ('Type') {|member| member.committee_member.committee_member_type.name rescue "<span class=light>None</span>".html_safe }
	        column ('Expertise') {|member| member.committee_member.expertise.truncate(50) rescue nil}
	        column ('Comment') do |member|
              span(member.comment, class: 'light smaller')
	        end
	        column ('Last Response') {|member| relative_timestamp(member.committee_member.last_user_response_at, :date_only => true, :empty_string => "Never") rescue nil}
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