require 'tmail'

ActiveAdmin.register EmailQueue do
  config.filters = false
  config.sort_order = 'created_at_desc'
  config.per_page = [30, 50, 100, 200]
  actions :all, :except => [:new]
  menu label: "Email Queue"
  menu parent: 'Tools'

  index do
  	selectable_column
  	column ('To') {|queue| queue.email.to || "" }
  	column ('From') {|queue| queue.email.from || "" }
  	column ('Subject') {|queue| queue.email.subject  || "" }
  	column ('Queued') {|queue| time_ago_in_words(queue.updated_at.to_s + " ago") }
  	actions
  end


end