RSpec.configure do |config|
  config.use_transactional_fixtures = true
  # Use color in STDOUT

  # Use color not only in STDOUT but also in pagers and files

  # Use the specified formatter
  # config.formatter = :documentation # :progress, :html, :textmate

  config.before(:suite) do
    Delayed::Worker.delay_jobs = false
  end
end
