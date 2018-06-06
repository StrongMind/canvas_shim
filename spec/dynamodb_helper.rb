RSpec.configure do |config|
  config.before(:each) do
    Process.fork do
      puts `docker run --name shim_dynamodb -p 8000:8000 dwmkerr/dynamodb`
    end
  end

  config.after(:each) do
    `docker kill shim_dynamodb; docker rm shim_dynamodb`
  end
end
