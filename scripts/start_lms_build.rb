require Rails.root.join("scripts/travis.rb").to_s

travis = Travis.new auth_token: '2Zs3QvPdUqpWXL1kB-aM5A', repo_slug: "StrongMind%2Fcanvas-lms"

travis.create_request branch: '19-04-15-shim-specs-in-lms'
sleep 5
puts "Build id assigned: #{travis.build_id}"
puts "Build check: #{travis.check_build}"
