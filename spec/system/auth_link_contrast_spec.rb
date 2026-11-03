# frozen_string_literal: true

require 'rails_helper'

# WCAG 1.4.3: auth content links must keep ≥4.5:1 against their actual background
# in resting, hover, focus, and active. Shared body hover uses $michigan_summer_blue
# (#005499), not gold (header-only).
RSpec.describe 'Auth link contrast', type: :system do
  MIN_RATIO = 4.5
  PSEUDO_STATES = {
    resting: [],
    hover: ['hover'],
    focus: ['focus'],
    'focus-visible': ['focus-visible'],
    active: ['active']
  }.freeze

  def enable_cdp_css!
    browser = page.driver.browser
    browser.execute_cdp('DOM.enable')
    browser.execute_cdp('CSS.enable')
  end

  def node_id_for(selector)
    browser = page.driver.browser
    doc = browser.execute_cdp('DOM.getDocument', depth: 0)
    result = browser.execute_cdp(
      'DOM.querySelector',
      nodeId: doc.dig('root', 'nodeId'),
      selector: selector
    )
    node_id = result['nodeId']
    expect(node_id).to be > 0, "expected DOM node for #{selector.inspect} on #{page.current_path}"
    node_id
  end

  def force_pseudo!(node_id, classes)
    page.driver.browser.execute_cdp(
      'CSS.forcePseudoState',
      nodeId: node_id,
      forcedPseudoClasses: classes
    )
  end

  def parse_css_color(value)
    return nil if value.nil? || value == 'transparent'

    if (match = value.match(/\Argba?\(\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)(?:\s*,\s*([\d.]+))?\s*\)\z/i))
      r, g, b = match[1, 3].map(&:to_f)
      alpha = (match[4] || '1').to_f
      return nil if alpha <= 0

      [r, g, b, alpha]
    elsif (match = value.match(/\A#([0-9a-f]{6})\z/i))
      hex = match[1]
      [hex[0, 2], hex[2, 2], hex[4, 2]].map { |part| part.to_i(16).to_f } + [1.0]
    elsif (match = value.match(/\A#([0-9a-f]{3})\z/i))
      hex = match[1]
      [hex[0], hex[1], hex[2]].map { |part| (part * 2).to_i(16).to_f } + [1.0]
    else
      raise "unsupported CSS color #{value.inspect}"
    end
  end

  def relative_luminance(rgb)
    channels = rgb.first(3).map do |channel|
      c = channel / 255.0
      c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055)**2.4
    end
    (0.2126 * channels[0]) + (0.7152 * channels[1]) + (0.0722 * channels[2])
  end

  def contrast_ratio(foreground, background)
    lighter, darker = [relative_luminance(foreground), relative_luminance(background)].minmax.reverse
    (lighter + 0.05) / (darker + 0.05)
  end

  def composite_over(fg, bg)
    alpha = fg[3]
    [
      (fg[0] * alpha) + (bg[0] * (1 - alpha)),
      (fg[1] * alpha) + (bg[1] * (1 - alpha)),
      (fg[2] * alpha) + (bg[2] * (1 - alpha)),
      1.0
    ]
  end

  # Walk ancestors until an opaque background is found (actual painted backdrop).
  def colors_for(selector)
    result = page.evaluate_script(<<~JS)
      (function () {
        var el = document.querySelector(#{selector.to_json});
        if (!el) return null;
        var style = window.getComputedStyle(el);
        var color = style.color;
        var node = el;
        var background = 'rgba(0, 0, 0, 0)';
        while (node && node.nodeType === 1) {
          var bg = window.getComputedStyle(node).backgroundColor;
          if (bg && bg !== 'transparent' && bg !== 'rgba(0, 0, 0, 0)') {
            background = bg;
            break;
          }
          node = node.parentElement;
        }
        if (!node) background = 'rgb(255, 255, 255)';
        return { color: color, background: background, text: (el.textContent || '').trim() };
      })()
    JS

    expect(result).not_to be_nil, "missing element #{selector.inspect} on #{page.current_path}"
    fg = parse_css_color(result['color'])
    bg = parse_css_color(result['background']) || [255.0, 255.0, 255.0, 1.0]
    bg = composite_over(bg, [255.0, 255.0, 255.0, 1.0]) if bg[3] < 1.0
    {
      foreground: fg,
      background: bg,
      color_css: result['color'],
      background_css: result['background'],
      text: result['text']
    }
  end

  def mark_link!(text)
    el = find(:xpath, %{//main//a[normalize-space()=#{text.to_json}]}, match: :first)
    page.execute_script(<<~JS, el)
      document.querySelectorAll('a[data-contrast-target="1"]').forEach(function (node) {
        node.removeAttribute('data-contrast-target');
      });
      arguments[0].setAttribute('data-contrast-target', '1');
    JS
    'a[data-contrast-target="1"]'
  end

  def assert_contrast!(link_text:, selector:)
    expect(page).to have_link(link_text)
    node_id = node_id_for(selector)
    measured = {}

    PSEUDO_STATES.each do |state, classes|
      force_pseudo!(node_id, classes)
      sample = colors_for(selector)
      ratio = contrast_ratio(sample[:foreground], sample[:background])
      measured[state] = ratio.round(2)

      expect(ratio).to be >= MIN_RATIO, lambda {
        "#{link_text.inspect} #{state} contrast #{ratio.round(2)}:1 " \
          "(#{sample[:color_css]} on #{sample[:background_css]}) " \
          "on #{page.current_path}; need ≥#{MIN_RATIO}:1"
      }

      # Gold fails AA on white; content links must not use it outside the header.
      expect(sample[:color_css]).not_to match(/\Agold\z/i)
      goldish = parse_css_color('#ffd700')
      expect(sample[:foreground].first(3).map(&:round)).not_to eq(goldish.first(3).map(&:round)),
                                                                "#{link_text.inspect} #{state} resolved to gold on #{page.current_path}"
    end

    force_pseudo!(node_id, [])
    measured
  end

  def assert_built_css_avoids_body_gold!
    css = Rails.root.join('app/assets/builds/application.css').read
    expect(css).to include('a:hover,a:focus,a:focus-visible,a:active{color:#005499}')
    expect(css).to include('header a:hover{color:gold}')
    expect(css).to include('header a.avatar-login:hover')
    expect(css).to match(/header a\.avatar-login(?::[\w-]+)*(?:,header a\.avatar-login(?::[\w-]+)*)*\{color:#00274c\}/)
    without_header_gold = css.gsub('header a:hover{color:gold}', '')
    expect(without_header_gold).not_to include('a:hover{color:gold}')
  end

  before do
    enable_cdp_css!
  end

  it 'keeps sign-in content links AA-compliant without gold hover' do
    visit new_user_session_path
    expect(page).to have_content('Log in')

    sign_up = assert_contrast!(link_text: 'Sign up', selector: mark_link!('Sign up'))
    forgot = assert_contrast!(link_text: 'Forgot your password?', selector: mark_link!('Forgot your password?'))
    assert_built_css_avoids_body_gold!

    expect(sign_up.values).to all(be >= MIN_RATIO)
    expect(forgot.values).to all(be >= MIN_RATIO)
  end

  it 'keeps the sign-up Log in link AA-compliant without gold hover' do
    visit new_user_registration_path
    expect(page).to have_content('Sign up')

    login = assert_contrast!(link_text: 'Log in', selector: mark_link!('Log in'))
    assert_built_css_avoids_body_gold!

    expect(login.values).to all(be >= MIN_RATIO)
  end

  it 'keeps the header Login button AA-compliant on hover and active' do
    visit new_user_session_path
    expect(page).to have_css('header a.avatar-login', text: 'Login')

    measured = assert_contrast!(link_text: 'Login', selector: 'header a.avatar-login')
    assert_built_css_avoids_body_gold!

    expect(measured.values).to all(be >= MIN_RATIO)
  end
end
