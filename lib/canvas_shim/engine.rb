require 'delayed_job'
require 'csv'
require "rails"
require 'grape'
require 'grape-swagger'
require 'grape-swagger-ui'
require 'aws-sdk-dynamodb'
require "pipeline_publisher_ruby"
require "business"
require 'httparty'
require 'aws-sdk-core'
require 'aws-sdk-s3'
require 'inst-jobs'
require 'pg'
require 'byebug'
require "rspec-rails"

module CanvasShim
  class Engine < ::Rails::Engine
    config.autoload_paths << File.expand_path("app/services", __dir__)
    config.autoload_paths << File.expand_path("app/deploy", __dir__)

    isolate_namespace CanvasShim

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
