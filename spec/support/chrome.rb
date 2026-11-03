driver = :selenium_chrome_headless

Capybara.server = :puma, { Silent: true }

Capybara.register_driver driver do |app|
  options = Selenium::WebDriver::Chrome::Options.new

  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--window-size=1400,1400')

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = driver

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by driver
    # Rails wraps examples in a transaction before `before` hooks run.
    # The around hook in rails_helper also clears this, before `before_setup`.
    self.use_transactional_tests = false
  end

  # Must run outside Rails' fixture transaction. This around hook is registered
  # before the DatabaseCleaner around hook and stays outside `before_setup`.
  config.around(:each, type: :system) do |example|
    self.use_transactional_tests = false
    example.run
  end
end
