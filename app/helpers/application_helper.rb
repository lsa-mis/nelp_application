module ApplicationHelper
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
end
