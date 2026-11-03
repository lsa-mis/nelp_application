# frozen_string_literal: true

module HeadingStructureHelpers
  def main_from(html)
    doc = Nokogiri::HTML(html)
    main = doc.at_css('main')
    expect(main).to be_present, 'expected a <main> landmark in the response'
    main
  end

  def heading_nodes_in(container)
    container.css('h1, h2, h3, h4, h5, h6')
  end

  def assert_single_h1!(container, text: nil)
    h1s = container.css('h1')
    expect(h1s.size).to eq(1), "expected exactly one h1 in main, found #{h1s.size}: #{h1s.map(&:text).map(&:strip)}"
    expect(h1s.first.text.strip).to eq(text) if text
  end

  def assert_heading_levels_do_not_skip!(container)
    levels = heading_nodes_in(container).map { |node| node.name[/\d/].to_i }
    return if levels.empty?

    expect(levels.first).to eq(1), "expected outline to start at h1, got h#{levels.first}"

    levels.each_cons(2) do |previous, current|
      expect(current).to be <= previous + 1,
                         "heading level skipped: h#{previous} followed by h#{current} (#{levels.inspect})"
    end
  end
end

RSpec.configure do |config|
  config.include HeadingStructureHelpers, type: :request
end
