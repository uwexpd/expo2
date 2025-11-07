class UserMailer < ActionMailer::Base
  layout 'email'

  def welcome_signup(user)
    @user = user
    mail(to: @user.email, 
         subject: 'Welcome to UW EXPO online system',
         from: Rails.configuration.constants['system_help_email'],
         date: Time.now) do |format|
      format.html
      format.text
    end
  end

  def password_reminder(user, sent_at = Time.now)      
    @user = user
    @password_reset_link = reset_password_url(user.id, user.token.to_s, host: Rails.configuration.constants["base_url_host"], protocol: 'https')

    mail(to: @user.email, 
         subject: 'Password Reminder',
         from: Rails.configuration.constants['system_help_email'],
         date: sent_at) do |format|
      format.html
      format.text
    end
  end

  def username_reminder(email, users, sent_at = Time.now)
    @users = users
    @email = email
    mail(to: email,
         subject: 'Your UW EXPO Username Reminder',
         from: Rails.configuration.constants['system_help_email'],
         date: sent_at) do |format|
      format.html
      format.text
    end
  end

end
