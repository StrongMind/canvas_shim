require 'csv'
require 'grape'
require 'grape-swagger'
require 'grape-swagger-ui'
require 'aws-sdk-dynamodb'
require "business"
require 'httparty'
require 'aws-sdk-core'
require 'aws-sdk-s3'
require 'pg'
require "pipeline_publisher_ruby"

module CanvasShim
  class Engine < ::Rails::Engine
    isolate_namespace CanvasShim

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
