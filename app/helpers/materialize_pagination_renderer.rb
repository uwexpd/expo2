class MaterializePaginationRenderer < WillPaginate::ActionView::LinkRenderer
  TAB_PAGE_PARAMS = %w[active_page submitted_page deactivated_page all_page].freeze

  def html_container(html)
    tag(:ul, html, class: "pagination")
  end

  def page_number(page)
    if page == current_page
      tag(:li, @template.content_tag(:a, page, href: "#!", "aria-current": "page"), class: "active")
    else
      tag(:li, link(page, page, rel: rel_value(page)), class: "waves-effect")
    end
  end

  def previous_page
    previous_or_next(@collection.previous_page, "chevron_left", "Previous page")
  end

  def next_page
    previous_or_next(@collection.next_page, "chevron_right", "Next page")
  end

  def gap
    tag(:li, @template.content_tag(:a, "…", href: "#!"), class: "disabled")
  end

  # A page link should carry only its own page parameter. Without this,
  # navigating between tab panels can accumulate ?all_page=...&submitted_page=...
  # in the URL.
  def url(page)
    query = @template.request.query_parameters.except(*TAB_PAGE_PARAMS)
    query.merge!((@options[:params] || {}).stringify_keys)
    query[(@options[:param_name] || :page).to_s] = page

    @template.url_for(query.merge(only_path: true))
  end

  private

  def previous_or_next(page, icon, label)
    icon_html = @template.content_tag(:i, icon, class: "material-icons")

    if page
      tag(:li, link(icon_html, page, rel: rel_value(page), "aria-label": label), class: "waves-effect")
    else
      tag(:li, @template.content_tag(:a, icon_html, href: "#!", "aria-label": label, "aria-disabled": "true"), class: "disabled")
    end
  end
end
