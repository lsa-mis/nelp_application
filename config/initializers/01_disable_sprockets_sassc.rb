# This must load before Sprockets initializes
# Prevents LoadError for sassc when using dartsass-rails

if Rails.env.staging? || Rails.env.production?
  # Predefine the Sprockets autoload modules to prevent actual sassc loading
  require 'sprockets'

  module Sprockets
    module Autoload
      # Define a dummy SasscProcessor before Sprockets tries to autoload it
      module SasscProcessor
        def self.call(input)
          # dartsass handles SCSS compilation, so just pass through
          { data: input[:data] }
        end

        def self.cache_key
          'dartsass-dummy'
        end

        def self.instance
          self
        end
      end
    end

    # Define at top level too
    class SasscProcessor
      def self.call(input)
        { data: input[:data] }
      end

      def self.cache_key
        'dartsass-dummy'
      end

      def self.instance
        self
      end
    end
  end
end
