source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.4'
gem 'rails', '~> 7.2.2', '>= 7.2.2.1'

gem 'activeadmin'
gem 'base64'
gem 'bootsnap', '>= 1.4.4', require: false
gem 'csv'
gem 'dartsass-rails'
gem 'devise'
gem 'drb'
gem 'importmap-rails'
gem 'jbuilder', '~> 2.7'
gem 'pg'
gem 'puma', '~> 6.0'
gem 'sd_notify'
gem 'sentry-rails'
gem 'sentry-ruby'
gem 'simple_form'
gem 'sprockets-rails', '~> 3.4'
gem 'stimulus-rails'
gem 'turbo-rails'
gem 'tzinfo-data', platforms: %i[windows jruby]

group :development do
  gem 'annotate'
  gem 'capistrano', '~> 3.17', require: false
  gem 'capistrano-asdf', require: false
  gem 'capistrano-rails', '~> 1.6', '>= 1.6.1', require: false
  gem 'listen', '~> 3.3'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'spring', '~> 4.0'
  gem 'web-console', '>= 4.1.0'
  # Procfile process manager used by bin/dev
  gem 'foreman'
  # Ruby LSP and supporting tooling for editor features
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'ruby-lsp'
  gem 'ruby-lsp-rails'
  gem 'ruby-lsp-rspec'
  gem 'syntax_tree'
end

group :development, :test do
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'rspec-sqlimit'
  gem 'selenium-webdriver', '~> 4.11'

  # Additional testing gems for comprehensive coverage
  gem 'database_cleaner-active_record'
  gem 'shoulda-matchers', '~> 5.0'
  gem 'simplecov', require: false
  gem 'webmock'
end

group :development, :staging do
  gem 'letter_opener_web'
end
