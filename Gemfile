source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.3.4'
gem 'rails', '~> 7.2.2', '>= 7.2.2.1'

gem 'activeadmin'
gem 'base64'
gem 'bootsnap', '>= 1.4.4', require: false
gem 'csv'
gem 'drb'
gem 'devise'
gem 'jbuilder', '~> 2.7'
gem 'pg'
gem 'puma', '~> 5.0'
gem 'sassc-rails'
gem "sd_notify"
gem 'simple_form'
gem 'sprockets-rails'
gem 'turbolinks', '~> 5'
gem 'turnout', '~> 2.5'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'webpacker', '~> 5.4'

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
end

group :development, :test do
  gem 'rspec-rails'
  gem 'rspec-sqlimit'
  gem 'rails-controller-testing'
  gem 'factory_bot_rails'
  gem 'capybara'
  gem "webdrivers"
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
