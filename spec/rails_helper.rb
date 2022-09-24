# This file is copied to spec/ when you run 'rails generate rspec:install'

require 'dotenv'
require 'pry-byebug'
Dotenv.load('.env.test')

require File.expand_path("../test_app/config/environment.rb", __FILE__)

# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?

# Why???  Autoloading seems broken unless we require these manually

 ##  this manual loading is really iffy, given we can't count on a specific load order
 ## loading these first because they have to be, we might find others over time

Dir[CanvasShim::Engine.root.join('app/services/pipeline_service/V2/noun.rb')].each { |f| require f }
Dir[CanvasShim::Engine.root.join('app/services/pipeline_service/V2/nouns/base.rb')].each { |f| require f }

Dir[CanvasShim::Engine.root.join('app/services/**/**/**/*.rb')].each{ |f| require f }

require 'spec_helper'
require 'rspec/rails'

# Add additional requires below this line. Rails is not loaded until this point!
require 'webmock/rspec'

# Add factory bot
require 'support/factory_bot'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[CanvasShim::Engine.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!
