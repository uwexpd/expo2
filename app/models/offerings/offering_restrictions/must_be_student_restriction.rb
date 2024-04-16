class MustBeStudentRestriction < OfferingRestriction

  include Rails.application.routes.url_helpers
  
  def allows?(application_for_offering)
    @person = application_for_offering.person
    @person.is_a? Student
  end

  def title
    "You must be logged in as a student."
  end

  def detail
    "In order to apply for the #{self.offering.name}, you must be logged in as a student at the #{Rails.configuration.constants['university_name']}.  You are currently logged in as a non-student user, so you cannot continue with this application.
     <br><br>
     You can also try switching to your UW student role if it exists: <a href='#{login_as_student_path}' class='btn small'>Switch to your student role</a>
    ".html_safe
  end
  
  
end
