ActiveAdmin.register CommitteeMember, as: 'member' do
  belongs_to :committee
  includes :person
  batch_action :destroy, false
  # actions :all, :except => [:destroy]
  config.per_page = [25, 50, 100, 150, 200]

  # scope 'All', :sorting, default: true

  permit_params :committee_member_type_id, :department, :expertise, :website_url, :recommender_id, :inactive, :permanently_inactive, :comment, :notes, committee_member_quarter_attributes: [:active, :comment]

  batch_action :send_emails, confirm: "Are you sure??" do |ids|
    
  end

  batch_action :mark_as_active, confirm: "Are you sure??" do |ids|
    
  end

  batch_action :mark_active_as_user_response, confirm: "Are you sure??" do |ids|
    
  end

  batch_action :mark_as_inactive, confirm: "Are you sure??" do |ids|
    
  end

  batch_action :mark_as_permanently_inactive, confirm: "Are you sure??" do |ids|
    
  end

  index do
    selectable_column
    column ('Name') {|member| link_to member.person.firstname_first,  admin_committee_member_path(committee, member) }
    column ('Type') {|member| member.committee_member_type.name rescue 'None'}
    column 'Department <br>Expertise'.html_safe do |member|
      text_node "#{member.department}"
      br
      small "#{member.expertise}".truncate(50, omission: '... (continued)')
    end
    # upcoming = committee.quarters.upcoming.first

    column "Quarter" do |member|
      if member.currently_active? && member.status_cache != "not_responded"
         for q in committee.quarters.upcoming
            span 'person_check', :class => 'material-icons md-32' if member.active_for?(q)
         end
      end
    end
    column ('Last Response') {|member| relative_timestamp(member.last_user_response_at, :date_only => true, :empty_string => "Never") }
    actions
  end

  show :title => proc{|member|member.fullname} do
    attributes_table do
      row :person
      row :email
      row :committee_member_type
      row :department
      row :expertise
      row ('website'){|member| member.website_url}
      row ('last user update'){|member| member.last_user_response_at.nil? ? "Never".html_safe : relative_timestamp(member.last_user_response_at)}
      unless member.currently_active?
        row('Inactive') do |member|
          status_tag member.permanently_inactive? ? "** PERMANENTLY INACTIVE **" : "For current year", class: 'red'
        end
      end
    end
    panel "Quarters" do
        paginated_collection(member.committee_member_quarters.page(params[:page]).per(10).order('id DESC'), download_links: false) do
          table_for(collection, sortable: false) do
            column('Quarter'){|quarter| link_to quarter.quarter.title, admin_committee_committee_quarter_path(committee, quarter.committee_quarter)}
            column('Active?'){|quarter| status_tag "Yes", class: 'green small' if quarter.active?}
            column('Comments'){|quarter| quarter.comment}
          end
        end
    end
    panel "Meetings" do 
        paginated_collection(member.committee_member_meetings.page(params[:page]).per(15).order('id DESC'), download_links: false) do
          table_for(collection, sortable: false) do
            column('Meeting'){|meeting| link_to "#{meeting.committee_meeting.title} (#{meeting.committee_meeting.start_date.year})", 
          admin_committee_meeting_path(committee, meeting.committee_meeting)}
            column('Attending?'){|meeting| status_tag "Yes", class: 'green small' if meeting.attending?}
            column('Comments'){|meeting| meeting.comment}
          end
        end
    end
  end

  sidebar "Review History", only: :show do
  end

  sidebar "Instructions", only: :edit do
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    tabs do
      tab 'Details' do
        f.inputs do
          f.input :person_id,  input_html: { style: 'width: 25%'}
          f.input :committee_member_type_id, as: :select, collection: committee.member_types.pluck(:name, :id), include_blank: false
          f.input :department
          f.input :expertise
          f.input :website_url
          f.input :recommender_id, as: :select, collection: CommitteeMember.where(committee_id: committee.id).includes(:person).collect{|m| [m.fullname, m.id]}, include_blank: true, input_html: {class: 'select2'}
          f.input :inactive, hint: 'This member will not be able to join the team this year but should be contacted in the future..'
          f.input :permanently_inactive, hint: 'This member has left the UW or is not able to participate in the selection process in the future.'
          f.input :comment, as: :text, input_html: {rows:2}
          f.input :notes, as: :text, input_html: {rows:2}
        end
      end
      tab 'Quarters' do
        render 'admin/committees/committee_members/quarters', { member: member}
      end
    end
    f.actions
  end

  filter :person_firstname, label: 'Member firstname', as: :string
  filter :person_lastname, label: 'Member lastname', as: :string

end