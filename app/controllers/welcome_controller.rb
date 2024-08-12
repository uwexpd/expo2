class WelcomeController < ApplicationController
  
  def index
    add_breadcrumb  "EXPD", "https://expd.uw.edu"
    add_breadcrumb  "EXPO Activities"
    redirect_to admin_path if @current_user.admin?
    
    @person = @current_user.person
    @person_apps = @person.application_for_offerings
    @student = @person if @person.is_a?(Student)
    @service_learning_courses = @student ? @student.enrolled_service_learning_courses(Quarter.current_quarter, nil) : @person.service_learning_courses
    #[TODO] query previous quarters: @student.enrolled_service_learning_courses(Quarter.where("year > ?", 2007).to_a, nil) when request

    # @units = Unit.with_description.for_welcome_screen.limit(3)
    
  end

end
