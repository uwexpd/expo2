require 'tmail'
ActiveAdmin.register EmailQueue do
  config.filters = false
  config.sort_order = 'created_at_desc'
  config.per_page = [30, 50, 100, 200]
  actions :all, :except => [:new]
  menu parent: 'Tools', label: -> {"Email Queue (#{EmailQueue.messages(current_user).size})"}

  permit_params :person_id, :email

  controller do
    def scoped_collection      
      EmailQueue.messages(current_user)
    end

    def update
      email_queue = EmailQueue.find(params[:id])
      attrs = params.require(:email_queue).require(:email)

      old_mail = email_queue.email

      message_delivery  = TemplateMailer.text_message(
        template_object_for(email_queue),
        attrs[:from].to_s,
        attrs[:subject].to_s,
        attrs[:body].to_s,
        '', # link intentionally ignored for admin-edited queued emails
        recipients_from(attrs[:to])
      )
      
      # TemplateMailer.text_message returns ActionMailer::MessageDelivery in Rails 4+.
      # EmailQueue#email serializes a Mail::Message, so unwrap the real message.
      new_mail = message_delivery.respond_to?(:message) ? message_delivery.message : message_delivery

      # TemplateMailer sets to/from/subject/body. Preserve/edit optional headers too.
      new_mail.cc  = recipients_from(attrs[:cc]) if attrs.key?(:cc)
      new_mail.bcc = recipients_from(attrs[:bcc]) if attrs.key?(:bcc)

      # If you need to preserve delivery behavior from the queued message, copy it.
      # This is useful in development if the original queued message used letter_opener
      # or a specific delivery method.
      copy_delivery_settings!(from: old_mail, to: new_mail)

      # Reassign the serialized Mail::Message and mark it dirty so Rails saves the
      # regenerated multipart message back into email_queues.email.
      email_queue.email = new_mail
      email_queue.email_will_change!

      respond_to do |format|
        if email_queue.save
          flash[:notice] = 'E-mail was successfully updated and re-queued.'
          format.html { redirect_to action: 'show' }
          format.xml  { head :ok }
        else
          format.html { render action: 'edit' }
          format.xml  { render xml: email_queue.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def template_object_for(email_queue)
      email_queue.contactable || email_queue.person
    end

    # ActiveAdmin form fields may submit comma-separated strings for cc/bcc/to.
    # Mail accepts strings, but normalizing blank values avoids empty Cc/Bcc headers.
    def recipients_from(value)
      value.to_s.split(',').map(&:strip).reject(&:blank?)
    end

    def copy_delivery_settings!(from:, to:)
      to.delivery_method(from.delivery_method.class, from.delivery_method.settings) if from.delivery_method
      to.perform_deliveries = from.perform_deliveries
      to.raise_delivery_errors = from.raise_delivery_errors
    rescue NoMethodError
      # Some delivery methods may not expose settings. In that case, use the
      # default ActionMailer delivery configuration for the regenerated message.
      true
    end
    
  end

  batch_action :deliver, priority: 1, confirm: "Are you sure to deliver these email queues?" do |ids|
    total = 0
    failed = 0
    batch_action_collection.find(ids).each do |email_queue|
      begin
        email_queue.release
        total += 1
      rescue Exception => e
        failed += 1
        # Log to Rails logger so it shows up in production logs
        Rails.logger.error "[EmailQueue#deliver] Failed for id=#{email_queue.id}: #{e.class} - #{e.message}"
        Rails.logger.error e.backtrace.first(5).join("\n")
        email_queue.update_attribute(:error_details, e.message)
      end
    end
    notice = "Successfully delivered #{total} #{"email queue".pluralize(total)}."
    notice += " #{failed} failed — check error_details for details." if failed > 0

    redirect_to request.referer, notice: notice
  end

  batch_action :destroy, confirm: "Are you sure you want to delete these email queues?" do |ids|
    total = 0
    batch_action_collection.find(ids).each do |email_queue|
      email_queue.destroy
      total += 1
    end
    redirect_to request.referer, notice: "Successfully deleted #{total} email " + "queue".pluralize(total) + "."
  end

  action_item :deliver_now , only: :show, priority: 1 do
    link_to 'deliver now', release_admin_email_queue_path(email_queue), data: { confirm: 'Are you sure?' }
  end

  member_action :release do
    email_queue = EmailQueue.find(params[:id])
    begin
        email_queue.release
    rescue Exception => e
      email_queue.update_attribute(:error_details, e.message)
    end
    redirect_to admin_email_queues_path, notice: "Successfully deliver email to #{email_queue.email_to}"
  end

  index :download_links => false do
  	selectable_column
  	column ('To') {|queue| queue.email_to || "" }
  	column ('From') {|queue| queue.email_from.to_s || "" }
  	column ('Subject') {|queue| link_to queue.email.subject, admin_email_queue_path(queue) rescue "" }
  	column ('Queued') {|queue| time_ago_in_words(queue.updated_at.to_s + " ago") }
  	actions
  end

  show :title => proc{|queue| "Send to: " + queue.email_to rescue ""} do |queue|
    # render 'show', { queue: email_queue}
    attributes_table do
       row ('To') {|queue| queue.email_to rescue "" }       
       row ('From') {|queue| queue.email_from rescue "" }
       row ('Subject') {|queue| queue.email.subject  || "" }
       row ('Cc') {|queue| queue.email.cc.join(',').to_s rescue "" } if queue.email.cc
       row ('Bcc') {|queue| queue.email.bcc.join(',') rescue "" } if queue.email.bcc
       row ('Body'){|queue| simple_format(EmailBodyExtractor.extract(queue.email)[:text]) rescue simple_format(queue.email.body.to_s) }
    end
  end

  form partial: 'edit'

end