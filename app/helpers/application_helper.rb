module ApplicationHelper
  include Pagy::Frontend

  # Returns the full title on a per-page basis.
  def full_title(page_title = '')
    base_title = 'NELP Payments'
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end

  def sentry_trace_propagation_meta
    return ''.html_safe unless defined?(Sentry)

    Sentry.get_trace_propagation_meta.html_safe
  rescue Encoding::CompatibilityError, ArgumentError
    ''.html_safe
  end

  def admin_sort_link(label, column, current_column:, current_order:, **options)
    next_order = current_column == column && current_order == 'asc' ? 'desc' : 'asc'
    indicator = if current_column == column
                  current_order == 'asc' ? ' ▲' : ' ▼'
                else
                  ' ⇅'
                end

    link_to "#{label}#{indicator}",
            admin_root_path(sort_column: column, sort_order: next_order, page: options[:page]),
            title: 'Click to sort',
            class: options[:class]
  end
end
