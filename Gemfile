source 'https://rubygems.org'

# Declare your gem's dependencies in canvas_shim.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

gem 'delayed_job_active_record'
gem 'pg'
gem 'rails', '~> 5.0.7.2'

group :test do
  gem 'webmock'
end

group :development, :test do
  gem 'byebug', groups: ['development', 'test']
  gem 'dotenv-rails'
  gem 'faker'
  gem 'pry-byebug'
  gem 'rspec-rails', '~> 3'
  gem 'spring'
  gem 'awesome_print'
end