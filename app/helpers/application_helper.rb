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

  def subtitle(content)
    content_for(:after_page_title) {
      content_tag('span', content, :class => 'after_page_title') unless content.nil?
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

  def mark_as_confidential(note = nil)
    note ||= "CONFIDENTIAL"
    content_for(:confidentiality_note) do
      "&bull; #{note} &bull;"
    end
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

  def status_tag(boolean)
    value = boolean ? 'YES' : 'NO'
    "<span class='status_tag #{value.downcase}'>" + value + "</span>"
  end

  # Creates a separator
  def separator(text = "or")
    "<span class=\"separator\"> &ndash; #{text} &ndash; </span>"
  end

  # def tooltip(link_text, content, options = {})
  #   full_link_text = "#{link_text}"
  #   full_link_text << content_tag(:div, content, :class => 'content')
  #   options[:class] = options[:class].nil? ? 'tooltip' : "#{options[:class]} tooltip"
  #   return link_to(full_link_text, options.delete(:url) || nil, options) if options[:url]
  #   content_tag(:a, full_link_text, options)
  # end

  # Tries to produce a human-readable phone number. Strips all non-digits and then feeds to number_to_phone
  def phone_number(number)
    number.nil? ? "" : number_to_phone(number.to_s.strip[0..9], :area_code => true, :extension => number.to_s.strip[10..20])
  end

  # Truncates a string to the first line-break or number of characters, whichever comes first.
  def truncate_to_whitespace(text, length = 100, truncate_string = "...")
    if text.nil? then return end
    text[0..text.index($/)] rescue text
  end
  
  # Truncates a string using truncate_to_whitespace but also includes a link to view the rest, which includes a Javascript link to expand.
  def truncate_to_whitespace_with_link(text, length = 100, truncate_string = "(continued)")
    if text.nil? then return end
    div_id = "truncate_" + rand(100000000000).to_s
    if text.index($/) # yes, we found whitespace - truncate to that
      before_text = text[0..text.index($/)]
      after_text = text[text.index($/)..text.length]
    else
      return text
    end
    str = before_text
    str << link_to_function(truncate_string, "Effect.toggle('#{div_id}', 'blind', {duration: 0.25})")
    str << "<div id='#{div_id}' style='display:none'>"
    str << simple_format(after_text)
    str << link_to_function("(show less)", "Effect.toggle('#{div_id}', 'blind', {duration: 0.25})")
    str << "</div>"
  end

  # Provides a printable version of the creation and update timestamps for the given object. If the object also
  # has a creator_id and updater_id, this method includes the creator and updater name.
  def object_timestamp_details(object)
    str = ""
    str << "Created " if object.created_at || object.creator
    str << "#{relative_timestamp(object.created_at)} " if object.created_at
    str << "by #{object.creator.firstname_first}" if object.creator rescue nil
    str << " | " unless str.blank?
    str << "Last edited " if object.updated_at || object.updater
    str << "#{relative_timestamp(object.updated_at)} " if object.updated_at
    str << "by #{object.updater.firstname_first}" if object.updater rescue nil
    str
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

  def pluralize_without_count(count, noun, text = nil)
    if count != 0
      count == 1 ? "#{noun}#{text}" : "#{noun.pluralize}#{text}"
    end
  end

  # Generates a caption element and computes any generated content within it (e.g., converts %foo% into "bar")
  def display_computed_caption(caption)
    caption.gsub!(/\%([a-z0-9_.]+)\%/) { |a| eval("@user_application.#{a.gsub!(/\%/,'')}") }
    content_tag('span', caption.html_safe, :class => 'helper-text')
  end
  
  # Provides a link of class "help" that opens a popup with the help_text for the supplied question.
  def help_link(question)
    return nil if question.help_text.blank?
    link_text = question.help_link_text.blank? ? "Help" : question.help_link_text
    link_to link_text, 
          apply_help_url(question.offering, question),
          class: 'help',
          target: '_blank'
    
  end

end
