require 'tmail'

ActiveAdmin.register EmailQueue do
  config.filters = false
  config.sort_order = 'created_at_desc'
  config.per_page = [30, 50, 100, 200]
  actions :all, :except => [:new]
  menu label: "Email Queue"
  menu parent: 'Tools'

  permit_params :person_id, :email

  controller do
    def scoped_collection    
      EmailQueue.messages(:current_user)
    end

    def update
      @email = EmailQueue.find(params[:id])
      @email.email.to = params[:email_queue][:email][:to]
      @email.email.from = params[:email_queue][:email][:from]
      @email.email.subject = params[:email_queue][:email][:subject]
      @email.email.cc = params[:email_queue][:email][:cc]
      @email.email.bcc = params[:email_queue][:email][:bcc]
      @email.email.body = params[:email_queue][:email][:body]

      respond_to do |format|
        if @email.save
          flash[:notice] = "E-mail was successfully updated and re-queued."
          format.html { redirect_to :action => "show" }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @email.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  batch_action :deliver, priority: 1, confirm: "Are you sure to deliver these email queues?" do |ids|
    total = 0
    batch_action_collection.find(ids).each do |email_queue|
      begin
        email_queue.release
        total += 1
      rescue Exception => e
        email_queue.update_attribute(:error_details, e.message)
      end
    end
    redirect_to request.referer, notice: "Successfully deliver #{total} email " + "queue".pluralize(total) + "."
  end

  batch_action :destroy, confirm: "Are you sure you want to delete these email queues?" do |ids|
    total = 0
    batch_action_collection.find(ids).each do |email_queue|
      email_queue.destroy
      total += 1
    end
    redirect_to request.referer, notice: "Successfully deleted #{total} email " + "queue".pluralize(total) + "."
  end


  index :download_links => false do
  	selectable_column
  	column ('To') {|queue| queue.email[:to].to_s || "" }
  	column ('From') {|queue| queue.email[:from].to_s || "" }
  	column ('Subject') {|queue| link_to queue.email.subject, admin_email_queue_path(queue) rescue "" }
  	column ('Queued') {|queue| time_ago_in_words(queue.updated_at.to_s + " ago") }
  	actions
  end

  show :title => proc{|queue| "Send to: " + queue.email.to.join(',') || ""} do
    render 'show', { email: email_queue.email}
    # attributes_table do
    #    row ('To') {|queue| queue.email[:to].to_s || "" }
    #    row ('Cc') {|queue| queue.email[:cc].to_s || "" }
    #    row ('Bcc') {|queue| queue.email[:bcc].to_s || "" }
    #    row ('From') {|queue| queue.email[:from].to_s || "" }
    #    row ('Subject') {|queue| queue.email.subject  || "" }
    #    row ('Body') {|queue| queue.email.body }
    # end
  end

  form partial: 'edit'

end