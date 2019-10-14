$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "canvas_shim/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "canvas_shim"
  s.version     = CanvasShim::VERSION
  s.authors     = [""]
  s.email       = [""]
  s.homepage    = "http://www.strongmind.com"
  s.summary     = "A tool to make it easy to write code that plugs into canvas"
  s.description = "A rails engine to be integrated with Canvas"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency 'aws-sdk-core'
  s.add_dependency 'aws-sdk-s3'
  s.add_dependency 'aws-sdk-sqs'
s.add_dependency 'aws-sdk-dynamodb', '~> 1.3'
  s.add_dependency 'aws-sdk-secretsmanager'

  s.add_dependency "pipeline_publisher_ruby"
  s.add_dependency "business"
  s.add_dependency 'httparty'
s.add_dependency "loofah", "2.3.0"
  s.add_dependency 'pandarus', '0.7.0'
  s.add_dependency 'decorators'
  s.add_dependency 'groupdate'
  s.add_dependency 'sass-rails', '5.0.7'
  s.add_dependency 'coffee-rails'
  s.add_dependency 'uglifier'
  s.add_dependency 'chronic'  
  
  s.add_development_dependency 'better_errors'
  s.add_development_dependency 'binding_of_caller'
  s.add_development_dependency 'pry-rails'
end
