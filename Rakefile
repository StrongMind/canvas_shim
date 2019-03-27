begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'CanvasShim'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

APP_RAKEFILE = File.expand_path("../spec/test_app/Rakefile", __FILE__)
task :default => ['app:spec:services', 'app:spec:models', 'app:spec:test_app']
load 'rails/tasks/engine.rake'
load 'rails/tasks/statistics.rake'
require 'bundler/gem_tasks'
