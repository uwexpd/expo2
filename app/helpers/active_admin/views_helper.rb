module ActiveAdmin::ViewsHelper
  
  # Returns the current Active Admin application instance
  def active_admin_application
    ActiveAdmin.application
  end
        
  def render_or_call_method_or_proc_on(obj, string_symbol_or_proc, options = {})
      case string_symbol_or_proc
      when Symbol, Proc
        call_method_or_proc_on(obj, string_symbol_or_proc, options)
      when String
        string_symbol_or_proc
      end
    end 
    
  # Returns all the flash keys to display in any Active Admin view.
  # This method removes the :timedout key that Devise uses by default.
  # Note Rails >= 4.1 normalizes keys to strings automatically.
  def flash_messages
    @flash_messages ||= flash.to_hash.with_indifferent_access.except(*active_admin_application.flash_keys_to_except)
  end

  # Creates a check_box_tag used for selecting an object from a list, in the format +select[:object_class][:object_id]+. Also gives the
  # element a CSS class of +select_check_box+ which can be used to select all of these check boxes on a page. An optional +css_class_id+
  # allows you to add an extra css class that can be used to only select certain check boxes on the page.
  def select_check_box(obj, group = nil, user_options = {})
    options = { :value => "1" }
    options.merge!(user_options)
    css_class = "select_check_box"
    css_class << " #{group}" unless group.nil?
    options[:class] = css_class
    check_box_tag "select[#{obj.class}][#{obj.id}]", options[:value], false, options
  end
  
  # Creates a check_box_tag used for selecting all select_check_boxes on the page. See select_check_box for options.
  def select_all_check_box(group = nil, options = {})
    css_class = "select_check_box"
    css_class_group = ".#{group}" unless group.nil?    
    field_id = "select_all_check_box_#{group}"
    css_class << " #{group} select_all"
    check_box_tag(field_id, "1", false, class: css_class)
  end
    
end