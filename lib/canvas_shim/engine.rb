require 'csv'
require 'grape'
require 'aws-sdk-dynamodb'
require 'business'
require 'httparty'
require 'aws-sdk-core'
require 'aws-sdk-s3'
require 'pg'
require 'pipeline_publisher_ruby'
require 'pandarus'
require 'decorators'

module CanvasShim
  class Engine < ::Rails::Engine
    config.autoload_paths << File.expand_path("app/services", __dir__)
    config.autoload_paths << File.expand_path("app/deploy", __dir__)

    isolate_namespace CanvasShim

    config.generators do |g|
      g.test_framework :rspec
    end

    class << self
      attr_accessor :root
      def root
        @root ||= Pathname.new(File.expand_path('../../../', __FILE__))
      end
    end

    config.to_prepare do
      Decorators.register! Engine.root, Rails.root
    end

  end
end
