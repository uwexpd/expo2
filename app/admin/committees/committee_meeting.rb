ActiveAdmin.register CommitteeMeeting, as: 'meeting' do
  belongs_to :committee
  batch_action :destroy, false
  actions :all, :except => [:destroy]

  permit_params :title, :description, :location, :start_date, :end_date

  batch_action :send_emails do |ids|

  end

  index do
    column ('Title'){|meeting| link_to meeting.title, admin_committee_meeting_path(committee, meeting) }
    column ('Start Time'){|meeting| meeting.start_date.to_s(:date_time12) }
    column ('End Time'){|meeting| meeting.end_date.to_s(:date_time12) rescue nil }
    column ('Attending'){|meeting| CommitteeMemberMeeting.where(committee_meeting_id: meeting.id, attending: true).size}
    actions
  end

  show do
	div :class => 'panel panel_contents content-block' do
	  h2 meeting.title do
	    span("» #{pluralize(meeting.committee_member_meetings.attending.size, 'attendee')}", class: 'smaller gray')
	  end
	  index_table_for meeting.committee_member_meetings.attending, class: 'index_table', id: 'index_table_trainings' do
        selectable_column
        column ('Committee Member') {|attendee| link_to attendee.committee_member.fullname,
				admin_committee_member_path(committee, attendee.committee_member) rescue "(error)" }
        column ('Type') {|attendee| attendee.committee_member.committee_member_type.name rescue "<span class=light>None</span>".html_safe }
        column ('Expertise') {|attendee| attendee.committee_member.expertise.truncate(50) rescue nil}
        column ('Comment') do |attendee|
          span(attendee.comment, class: 'caption')
        end
      end
    end
  end

  sidebar "Meeting Details", only: :show do
	attributes_table_for meeting do
    row :start_date
	  row :end_date
	  row('Attendees'){|m| m.committee_member_meetings.attending.size }
	  row('Description') { |m| span m.description.truncate(250), class: 'smaller' }
	end
  end

  form do |f|
    semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :title, reqired: true
      f.input :description, input_html: { rows: 5 }
      f.input :location
      f.input :start_date, as: :date_time_picker, required: true
      f.input :end_date, as: :date_time_picker
    end
    f.actions
  end

  filter :title, as: :string
  filter :start_date, as: :date_range
  filter :end_date, as: :date_range

end