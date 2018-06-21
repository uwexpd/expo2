module ApplicationHelper
  
  # creates a sidebar element 
  #### relative sibebar:
  ## <% sidebar :with_selected %>
  #### absolute sibebar:
  ## <% sidebar "full/sidebar/path" %>
  #### side bar with locals:
  ## <% sidebar :with_selected, {:locals => {:local_name => local_value}} %>
  def sidebar(*blocks)
    options = blocks.reject{|b| !b.is_a? Hash}.first || {}
    
    blocks.reject!{|b| b.is_a? Hash}
    blocks.each do |b|
      content_for :sidebar do
        if b.is_a? Symbol
          render :partial => "shared/sideblock", :locals => { :sideblock_to_render => b, :options => options }
        else
          render :partial => "shared/sideblock_full_path", :locals => { :sideblock_to_render => b, :options => options }
        end
      end
    end
  end
  
  def title(page_title = "UW EXPD-Online", subtitle = nil)
    content_for(:page_title) { page_title }

    content_for(:unit_name) { 
      subtitle.nil? ? "" : subtitle 
    }

    content_for(:title) { 
      subtitle.nil? ? page_title : page_title + " > " + subtitle
    }
  end

  def page_entries_info(collection, options = {})
    entry_name = options[:entry_name] || (collection.empty?? 'item' :
        collection.first.class.name.split('::').last.titleize)
    if collection.total_pages < 2
      case collection.size
      when 0; "No #{entry_name.pluralize} found"
      else; "Displaying #{collection.size} #{entry_name.pluralize}"
      end
    else
      %{Displaying %d - %d of %d #{entry_name.pluralize}} % [
        collection.offset + 1,
        collection.offset + collection.length,
        collection.total_entries
      ]
    end
  end

  # Tries to produce a human-readable phone number. Strips all non-digits and then feeds to number_to_phone
  def phone_number(number)
    number.nil? ? "" : number_to_phone(number.to_s.strip[0..9], :area_code => true, :extension => number.to_s.strip[10..20])
  end
  
end
