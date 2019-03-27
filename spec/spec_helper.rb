# Rails Engine call
# `rails plugin new MY_ENGINE --dummy-path=spec/dummy --skip-test-unit --full --database=mysql`
# or `rails plugin new ENGINE_NAME --dummy-path=spec/dummy --skip-test-unit --mountable --database=mysql`
# Configure spec_helper.rb

require 'webmock/rspec'
require 'dotenv'

Dotenv.load('.env.development')

ENV["RAILS_ENV"] = "test"
ENV['CANVAS_DOMAIN'] = 'canvasdomain.com'
require File.expand_path("../test_app/config/environment.rb",  __FILE__)
require 'rspec/rails'

ENGINE_RAILS_ROOT=File.join(File.dirname(__FILE__), '../')
# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(ENGINE_RAILS_ROOT, "spec/support/**/*.rb")].each {|f| require f }
RSpec.configure do |config|
  config.use_transactional_fixtures = true
# Use color in STDOUT

# Use color not only in STDOUT but also in pagers and files

# Use the specified formatter
  config.formatter = :documentation # :progress, :html, :textmate

  config.before do
    Delayed::Worker.delay_jobs = false
  end

  config.after(:each) do
  end
end
