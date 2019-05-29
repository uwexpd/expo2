require 'tmail'

ActiveAdmin.register EmailQueue do
  config.filters = false
  config.sort_order = 'created_at_desc'
  config.per_page = [30, 50, 100, 200]
  actions :all, :except => [:new]
  menu label: "Email Queue"
  menu parent: 'Tools'

  controller do
    def scoped_collection    
      EmailQueue.messages(:current_user)
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
  	column ('Subject') {|queue| queue.email.subject  || "" }
  	column ('Queued') {|queue| time_ago_in_words(queue.updated_at.to_s + " ago") }
  	actions
  end

end