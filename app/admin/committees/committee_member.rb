ActiveAdmin.register CommitteeMember, as: 'members' do
  belongs_to :committee
  includes :person
  batch_action :destroy, false
  config.per_page = [50, 100, 150, 200]

  # scope 'All', :sorting, default: true

  index do
    selectable_column
    column ('Name') {|member| link_to member.person.firstname_first,  admin_committee_member_path(committee, member) }
    column ('Type') {|member| member.committee_member_type.name rescue 'None'}
    column 'Department <br>Expertise'.html_safe do |member|
      text_node "#{member.department}"
      br
      small "#{member.expertise}".truncate(50, omission: '... (continued)')
    end
    column ('Last Response') {|member| relative_timestamp(member.last_user_response_at, :date_only => true, :empty_string => "Never") }
    actions
  end

  filter :person_firstname, label: 'Member firstname', as: :string
  filter :person_lastname, label: 'Member lastname', as: :string

end