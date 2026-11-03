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

  # Action Text CMS HTML may include <h1>s. Demote them to <h2> so the page
  # template owns the sole document h1 (a11y heading outline).
  def demote_action_text_h1(rich_text)
    return ''.html_safe if rich_text.blank?

    rich_text.to_s.gsub(/<(\/?)h1(\b[^>]*)?>/i, '<\1h2\2>').html_safe
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
