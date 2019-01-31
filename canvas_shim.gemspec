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

  s.add_dependency 'grape', '~> 1'
  s.add_dependency 'grape-swagger', '~> 0'
  s.add_dependency 'grape-swagger-ui', '~> 2'
  s.add_dependency 'aws-sdk-dynamodb', '1.15.0'
  s.add_dependency "pipeline_publisher_ruby"
  s.add_dependency "business"
  s.add_dependency 'httparty'
  s.add_dependency "loofah", "2.2.3"
  s.add_dependency 'pandarus', '0.7.0'

  s.add_development_dependency 'better_errors'
  s.add_development_dependency 'binding_of_caller'
  s.add_development_dependency 'pry-rails'
  s.add_development_dependency 'pry-byebug'
end
