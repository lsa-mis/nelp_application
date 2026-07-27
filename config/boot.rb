ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

# Bootsnap's ISeq compile cache conflicts with Ruby coverage (SimpleCov) on Ruby 4+.
if ENV['DISABLE_BOOTSNAP'] == '1' || defined?(Coverage) || ENV['COVERAGE'] == 'true'
  # Skip bootsnap when coverage instrumentation is active.
else
  require 'bootsnap/setup' # Speed up boot time by caching expensive operations.
end
