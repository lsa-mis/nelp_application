class ActionTextInput < Formtastic::Inputs::StringInput

  def to_html
    input_wrapping do
      template.javascript_include_tag('trix', 'data-turbo-track': 'reload') +
        template.stylesheet_link_tag('trix') +
        label_html +
        builder.rich_text_area(method, input_html_options)
    end
  end
end
