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
    
end