source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.4'
gem 'rails', '~> 7.2.2', '>= 7.2.2.1'

gem 'activeadmin'
gem 'base64'
gem 'bootsnap', '>= 1.4.4', require: false
gem 'csv'
gem 'drb'
gem 'devise'
gem 'jbuilder', '~> 2.7'
gem 'pg'
gem 'puma', '~> 6.0'
gem 'dartsass-rails'
gem "sd_notify"
gem "sentry-ruby"
gem "sentry-rails"
gem 'simple_form'
gem 'sprockets-rails', '~> 3.4'
gem 'stimulus-rails'
gem 'turbo-rails'
gem 'importmap-rails'
gem 'tzinfo-data', platforms: [:windows, :jruby]

group :development do
  gem 'annotate'
  gem 'capistrano', '~> 3.17', require: false
  gem 'capistrano-rails', '~> 1.6', '>= 1.6.1', require: false
  gem 'capistrano-asdf',   require: false
  gem 'listen', '~> 3.3'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'spring', '~> 4.0'
  gem 'web-console', '>= 4.1.0'
  # Procfile process manager used by bin/dev
  gem 'foreman'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'rspec-sqlimit'
  gem 'rails-controller-testing'
  gem 'factory_bot_rails'
  gem 'capybara'
  gem 'selenium-webdriver', '~> 4.11'
  gem 'faker'

  # Additional testing gems for comprehensive coverage
  gem 'shoulda-matchers', '~> 5.0'
  gem 'simplecov', require: false
  gem 'database_cleaner-active_record'
  gem 'webmock'
end

group :development, :staging do
  gem "letter_opener_web"
end
