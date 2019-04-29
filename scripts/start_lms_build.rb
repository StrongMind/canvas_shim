require "./scripts/travis.rb"
require 'yaml'

# If PR grab branch from PR branch env
# If push build or non-PR, use branch env
branch = [ENV['TRAVIS_PULL_REQUEST_BRANCH'], ENV['TRAVIS_BRANCH']].find { |item| item.present?

travis = Travis.new auth_token: '2Zs3QvPdUqpWXL1kB-aM5A', repo_slug: "StrongMind%2Fcanvas-lms"

travis.create_request branch: branch

puts "Build id assigned: #{travis.build_id}"

File.open("travis_lms_build.yml", "w+") do |file|
  vars = {
    request_id: travis.request_id,
    build_id: travis.build_id
  }
  file.write(vars.to_yaml)
end
