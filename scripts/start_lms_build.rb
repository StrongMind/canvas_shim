require 'httparty'



# Trigger a debug build
JOB_ID     = '523737962'
AUTH_TOKEN = '2Zs3QvPdUqpWXL1kB-aM5A'

response = HTTParty.post("https://api.travis-ci.org/job/#{JOB_ID}/debug", {
  headers: {
    'Content-Type'       => 'application/json',
    'Accept'             => 'application/json',
    'Travis-API-Version' => '3',
    'Authorization'      => "token #{AUTH_TOKEN}"
  },
  body: {'quiet' => true}.to_json,
  debug_output: STDOUT
})

puts response.body, response.code, response.message, response.headers.inspect


# curl -s -X POST \
#   -H "Content-Type: application/json" \
#   -H "Accept: application/json" \
#   -H "Travis-API-Version: 3" \
#   -H "Authorization: token AUTH_TOKEN" \
#   -d "{\"quiet\": true}" \
#   https://api.travis-ci.org/job/JOB_ID/debug

------------------------------------------------------------------------------------

# Create a Request for a branch

REPO_SLUG="StrongMind%2Fcanvas-lms" # yes slash escaped necessary
BRANCH='19-04-15-shim-specs-in-lms'
AUTH_TOKEN = '2Zs3QvPdUqpWXL1kB-aM5A'

response = HTTParty.post("https://api.travis-ci.org/repo/#{REPO_SLUG}/requests", {
  headers: {
    'Content-Type'       => 'application/json',
    'Accept'             => 'application/json',
    'Travis-API-Version' => '3',
    'Authorization'      => "token #{AUTH_TOKEN}"
  },
  body: {
    'request' => {
      'branch' => BRANCH,
      'message': "Canvas LMS build API triggered via commit on Canvas Shim."
    }
  }.to_json,
  debug_output: STDOUT
})

puts response.body, response.code, response.message, response.headers.inspect

JSON.parse response.body
{
  "@type" => "pending",
  "remaining_requests" => 10,
  "repository" => {
      "@type" => "repository",
      "@href" => "/repo/14881496",
      "@representation" => "minimal",
      "id" => 14881496,
      "name" => "canvas-lms",
      "slug" => "StrongMind/canvas-lms"
  },
  "request" => {
    "repository" => {
      "id" => 100979704,
      "owner_name" => "StrongMind",
      "name" => "canvas-lms"
    },
    "user" => {
      "id" => 578135
    },
    "id" => 160840238,
    "message" => nil,
    "branch" => "19-04-15-shim-specs-in-lms",
    "config" => {}
  },
  "resource_type" => "request"
}

# body='{
# "request": {
# "branch":"master"
# }}'

# curl -s -X POST \
#    -H "Content-Type: application/json" \
#    -H "Accept: application/json" \
#    -H "Travis-API-Version: 3" \
#    -H "Authorization: token xxxxxx" \
#    -d "$body" \
#    https://api.travis-ci.com/repo/travis-ci%2Ftravis-core/requests


------------------------------------------------------------------------------------

# Get the status of a build


REPO_SLUG="StrongMind%2Fcanvas-lms" # yes slash escaped necessary
REQUEST_ID='160840238'
AUTH_TOKEN = '2Zs3QvPdUqpWXL1kB-aM5A'

response = HTTParty.get("https://api.travis-ci.org/repo/#{REPO_SLUG}/request/#{REQUEST_ID}", {
  headers: {
    'Content-Type'       => 'application/json',
    'Accept'             => 'application/json',
    'Travis-API-Version' => '3',
    'Authorization'      => "token #{AUTH_TOKEN}"
  },
  debug_output: STDOUT
})

puts response.body, response.code, response.message, response.headers.inspect

JSON.parse response.body
{
  "@type" => "request",
  "@href" => "/repo/14881496/request/160840238",
  "@representation" => "standard",
  "id" => 160840238,
  "state" => "finished",
  "result" => "approved",
  "message" => nil,
  "repository" => {
    "@type" => "repository",
    "@href" => "/repo/14881496",
    "@representation" => "minimal",
    "id" => 14881496,
    "name" => "canvas-lms",
    "slug" => "StrongMind/canvas-lms"
  },
  "branch_name" => "19-04-15-shim-specs-in-lms",
  "commit" => {
    "@type" => "commit",
    "@representation" => "minimal",
    "id" => 158216128,
    "sha" => "01a1867e903e7d096b009cc151979b7ab14ff2bb",
    "ref" => nil,
    "message" => "rm unused test gem",
    "compare_url" => "https://github.com/StrongMind/canvas-lms/compare/c326fa7ec483cba3451af40ff95fadb62a6c66c2...01a1867e903e7d096b009cc151979b7ab14ff2bb",
    "committed_at" => "2019-04-23T23:39:55Z"
  },
  "builds" => [
    {
      "@type" => "build",
      "@href" => "/build/524218743",
      "@representation" => "minimal",
      "id" => 524218743,
      "number" => "419",
      "state" => "started",
      "duration" => nil,
      "event_type" => "api",
      "previous_state" => "passed",
      "pull_request_title" => nil,
      "pull_request_number" => nil,
      "started_at" => "2019-04-24T22:13:06Z",
      "finished_at" => nil,
      "private" => false
  }],
  "owner" => {
    "@type" => "organization",
    "@href" => "/org/233199",
    "@representation" => "minimal",
    "id" => 233199,
    "login" => "StrongMind"
  },
  "created_at" => "2019-04-24T22:12:32Z",
  "event_type" => "api",
  "base_commit" => nil,
  "head_commit" => nil
}




------------------------------------------------------------------------------------
from ~/Projects/StrongMind/canvas-lms/vendor/canvas_shim/spec/test_app
be rails c
require Rails.root.join("../../scripts/travis.rb").to_s

travis = Travis.new auth_token: '2Zs3QvPdUqpWXL1kB-aM5A', repo_slug: "StrongMind%2Fcanvas-lms"

travis.create_request branch: '19-04-15-shim-specs-in-lms'
# travis.create_request_response['request']['id']

travis.build_id

travis.check_build


travis.list_requests
travis.list_requests_response["requests"].first

