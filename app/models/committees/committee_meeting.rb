class CommitteeMeeting < ApplicationRecord
  stampable
  belongs_to :committee
  has_many :committee_member_meetings, :dependent => :destroy do
    def attending; where(attending: true); end
    def not_attending; where(attending: false); end
  end

  after_create :add_committee_members_to_meeting

  validates_presence_of :title
  validates_presence_of :start_date
  
  def <=>(o)
    start_date <=> o.start_date
  end
  
  # Returns true if this meeting already occurred
  def past?
    start_date < Time.now
  end

  private

  def add_committee_members_to_meeting
    committee.members.each { |member| member.create_committee_member_meetings_if_needed(true) }
  end

end
