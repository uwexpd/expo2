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
  
  def address_block(obj, delimiter = "<br>")
    if obj.is_a? Person
      address_block_for_person(obj, delimiter)
    elsif obj.is_a? Location
      address_block_for_location(obj, delimiter)
    else
      nil
    end
  end
  
  # Creates a printable address block from a person record.
  def address_block_for_person(person, delimiter = "<br>")
    a = "#{person.address1}"
    a << "#{delimiter}#{person.address2}" unless person.address2.blank?
    a << "#{delimiter}#{person.address3}" unless person.address3.blank?
    a << "#{delimiter}" unless person.city.blank? || person.state.blank? || person.zip.blank?
    a << "#{person.city}" unless person.city.blank?
    a << ", " unless person.city.blank? && person.state.blank?
    a << "#{person.state} "
    a << "#{person.zip}"
  end
  
  # Creates a printable address block from a location record
  def address_block_for_location(location, delimiter = "<br>")
    a = "#{location.address_line_1}"
    a << "#{delimiter}#{location.address_line_2}" unless location.address_line_2.blank?
    a << "#{delimiter}" unless location.address_city.blank? || location.address_state.blank? || location.address_zip.blank?
    a << "#{location.address_city}" unless location.address_city.blank?
    a << ", " unless location.address_city.blank? && location.address_state.blank?
    a << "#{location.address_state} "
    a << "#{location.address_zip}"    
  end

  # time = Time as string, e.g. "13:00"
  # day = Day of week as string, e.g., "wednesday"
  # selected = Initial selected state of the cell. Defaults to false.
  # result_id = DOM ID of the form element to stick the results in
  def time_row_cell(time, day, result_id, selected = false, options = {})
    id = "time_#{time}_#{day.to_s}"
    onMouseDown = "startDragSelect(this, $('#{result_id}'));" unless options[:readonly]
    klass = "selectable_time #{options[:class]} #{"selected" if selected}"
    "<td id=\"#{id}\" onMousedown=\"#{onMouseDown}\" class=\"#{klass}\">#{options[:body]}</td>".html_safe
  end

  def status_tag(boolean)
    value = boolean ? 'YES' : 'NO'
    "<span class='status_tag #{value.downcase}'>" + value + "</span>"
  end
  
  # Creates a separator
  def separator(text = "or")
    "<span class=\"separator\"> &ndash; #{text} &ndash; </span>"
  end

end
