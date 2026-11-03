# frozen_string_literal: true

require 'rails_helper'

# Proves content reflows at a phone-width viewport without page-level horizontal scroll.
# Headless Chrome sometimes refuses a 320px window; CDP device metrics are the fallback.
RSpec.describe 'Viewport reflow', type: :system do
  LONG_EMAIL = 'very.long.email.address.that.must.wrap.at.three.hundred.twenty@umich.edu'

  # Headless Chrome on macOS clamps resize_to to about 500px. Device emulation
  # then sets the layout viewport to 320. mobile:true leaves window.innerWidth at
  # the clamped window size on this Chrome, so fall back to mobile:false which
  # reports innerWidth 320 while keeping the same layout width.
  def emulate_narrow_viewport!
    browser = page.driver.browser
    browser.manage.window.resize_to(320, 800)
    return if page.evaluate_script('window.innerWidth').to_i <= 360

    [true, false].each do |mobile|
      browser.execute_cdp(
        'Emulation.setDeviceMetricsOverride',
        width: 320,
        height: 800,
        deviceScaleFactor: 1,
        mobile: mobile
      )
      break if page.evaluate_script('window.innerWidth').to_i <= 360
    end
  end

  def assert_narrow_viewport!
    inner = page.evaluate_script('window.innerWidth').to_i
    expect(inner).to be <= 360, "expected a ~320px viewport, measured innerWidth #{inner} at #{page.current_path}"
    inner
  end

  def assert_no_horizontal_overflow!
    result = page.evaluate_script(<<~JS)
      (function () {
        window.scrollTo(0, 0);
        document.documentElement.scrollLeft = 0;
        document.body.scrollLeft = 0;
        var root = document.documentElement;
        var limit = root.clientWidth;
        var offenders = [];
        var nodes = document.body ? document.body.querySelectorAll('*') : [];
        for (var i = 0; i < nodes.length; i++) {
          var el = nodes[i];
          var tag = el.tagName;
          if (tag === 'SCRIPT' || tag === 'STYLE' || tag === 'LINK' || tag === 'META') continue;
          var ancestor = el.parentElement;
          var inScroll = false;
          while (ancestor && ancestor !== document.documentElement) {
            var overflowX = window.getComputedStyle(ancestor).overflowX;
            if (overflowX === 'auto' || overflowX === 'scroll') {
              inScroll = true;
              break;
            }
            ancestor = ancestor.parentElement;
          }
          if (inScroll) continue;
          var rect = el.getBoundingClientRect();
          if (rect.width === 0 && rect.height === 0) continue;
          var pastRight = rect.right - limit;
          var pastLeft = -1 - rect.left;
          if (pastRight > 1 || pastLeft > 0) {
            offenders.push({
              tag: tag,
              id: el.id || '',
              className: (el.getAttribute('class') || '').slice(0, 140),
              scrollWidth: el.scrollWidth,
              clientWidth: el.clientWidth,
              right: Math.round(rect.right),
              left: Math.round(rect.left),
              overflow: Math.round(Math.max(pastRight, pastLeft))
            });
          }
        }
        offenders.sort(function (a, b) { return b.overflow - a.overflow; });
        return {
          scrollWidth: root.scrollWidth,
          clientWidth: limit,
          innerWidth: window.innerWidth,
          offenders: offenders.slice(0, 8)
        };
      })()
    JS

    scroll_width = result['scrollWidth'].to_i
    client_width = result['clientWidth'].to_i
    inner_width = result['innerWidth'].to_i
    expect(scroll_width).to be <= (client_width + 1), lambda {
      lines = Array(result['offenders']).map do |item|
        "- #{item['tag']}##{item['id']}.#{item['className']} " \
          "scroll=#{item['scrollWidth']} client=#{item['clientWidth']} " \
          "left=#{item['left']} right=#{item['right']}"
      end
      detail = lines.empty? ? '(no element rects extended past the viewport)' : lines.join("\n")
      "#{page.current_path} overflows: scrollWidth #{scroll_width} > clientWidth #{client_width} " \
        "(innerWidth #{inner_width})\n#{detail}"
    }
  end

  def assert_controls_fit!(selectors)
    script = <<~JS
      (function () {
        var selectors = #{selectors.to_json};
        var limit = document.documentElement.clientWidth;
        return selectors.map(function (sel) {
          var el = document.querySelector(sel);
          if (!el) return { selector: sel, found: false };
          var rect = el.getBoundingClientRect();
          return {
            selector: sel,
            found: true,
            left: rect.left,
            right: rect.right,
            limit: limit,
            text: ((el.innerText || el.value || '') + '').replace(/\\s+/g, ' ').slice(0, 80)
          };
        });
      })()
    JS
    Array(page.evaluate_script(script)).each do |entry|
      selector = entry['selector']
      expect(entry['found']).to eq(true), "missing control #{selector} on #{page.current_path}"
      left = entry['left'].to_f
      right = entry['right'].to_f
      limit = entry['limit'].to_f
      message = "#{selector} (#{entry['text'].inspect}) on #{page.current_path} " \
                "left=#{left.round} right=#{right.round} viewport=#{limit.round}"
      expect(left).to be >= -1, message
      expect(right).to be <= (limit + 1), message
    end
  end

  def prepare_page!(path)
    visit path
    emulate_narrow_viewport!
    visit path
    assert_narrow_viewport!
    assert_no_horizontal_overflow!
  end

  describe 'signed-out public pages' do
    {
      'home' => :root_path,
      'about' => :about_path,
      'terms' => :terms_path,
      'privacy' => :privacy_path,
      'user login' => :new_user_session_path,
      'admin login' => :new_admin_user_session_path
    }.each do |name, route|
      it "keeps #{name} inside a 320px viewport" do
        prepare_page!(public_send(route))

        case route
        when :root_path
          expect(page).to have_content(/NELP Payment Portal/i)
          expect(page).to have_link('Login')
          expect(page).to have_content('There are no active programs')
          assert_controls_fit!(['span.title', 'a.avatar-login'])
        when :about_path, :terms_path, :privacy_path
          expect(page).to have_content(/NELP Payment Portal/i)
          expect(page).to have_link('Login')
          assert_controls_fit!(['span.title', 'a.avatar-login'])
        when :new_user_session_path
          expect(page).to have_content('Log in')
          expect(page).to have_content(/NELP Payment Portal/i)
          assert_controls_fit!(['span.title', 'a.avatar-login', 'input[type="email"]', 'input[type="submit"]'])
        when :new_admin_user_session_path
          expect(page).to have_content('Admin Login')
          assert_controls_fit!(['input[type="email"]', 'input[type="submit"]', 'h1'])
        end
      end
    end
  end

  it 'keeps the signed-in payment page inside a 320px viewport' do
    program = create(:program_setting, :active, program_year: Date.current.year)
    user = create(:user, email: LONG_EMAIL, password: 'password')
    sign_in user

    prepare_page!(all_payments_path)

    expect(page.html).to include(LONG_EMAIL)
    expect(page).to have_button('Pay application fee').or have_content(program.payment_instructions)
    assert_controls_fit!(['span.title', '.avatar-circle', 'button.btn-success'])
  end

  it 'keeps admin index pages inside a 320px viewport' do
    program = create(:program_setting, :active, program_year: Date.current.year)
    user = create(:user, email: LONG_EMAIL, password: 'password')
    create(:payment, user: user, program_year: program.program_year, transaction_status: '1')
    sign_in create(:admin_user)

    pages = {
      admin_root_path => 'User Payment Totals',
      admin_payments_path => 'Payments',
      admin_users_path => 'Users',
      admin_program_settings_path => 'Program Settings'
    }
    pages.each do |path, text|
      prepare_page!(path)
      expect(page).to have_content(text)
      expect(page).to have_css('.table-responsive')
      expect(page.html).to include(LONG_EMAIL) unless path == admin_program_settings_path
      assert_controls_fit!(['.navbar-brand', '.navbar-toggler', 'h1'])
    end
  end
end
