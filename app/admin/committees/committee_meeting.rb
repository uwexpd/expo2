ActiveAdmin.register CommitteeMeeting, as: 'meetings' do
	belongs_to :committee
	config.filters = false

end