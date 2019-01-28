# Load the Rails application.
require_relative 'application'

Dotenv::Railtie.load
# Initialize the Rails application.

Delayed::Worker.delay_jobs = false
Rails.application.initialize!
