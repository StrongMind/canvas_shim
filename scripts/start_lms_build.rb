require "./scripts/travis.rb"
require 'yaml'

travis = Travis.new auth_token: '2Zs3QvPdUqpWXL1kB-aM5A', repo_slug: "StrongMind%2Fcanvas-lms"

travis.create_request branch: '19-04-15-shim-specs-in-lms'

sleep 2

puts "Build id assigned: #{travis.build_id}"

File.open("travis_lms_build.yml", "w+") do |file|
  vars = {
    request_id: travis.request_id,
    build_id: travis.build_id
  }
  file.write(vars.to_yaml)
end
