require "./scripts/travis.rb"
require 'yaml'
require 'active_support/all'

travis = Travis.new auth_token: ENV['TRAVIS_API_TOKEN'], repo_slug: "StrongMind%2Fcanvas-lms"


build_values = YAML.load(File.read("travis_lms_build.yml")).with_indifferent_access

puts "Build values: #{build_values}"

build_id = build_values[:build_id]
state = nil

if build_id.present?
  loop do
    sleep 60
    state = travis.check_build(build_id: build_id)

    puts "Build check: #{state}"

    break if ['passed', 'failed', 'canceled'].include?(state)
  end

  # From Travis docs
  # If any of the commands in the first four phases of the job lifecycle return a non-zero exit code, the build is broken

  exit(1) unless state == 'passed'
else
  puts "No LMS build ID found, exiting with fail status"
  exit(1)
end
