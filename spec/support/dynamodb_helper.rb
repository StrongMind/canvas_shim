RSpec.configure do |config|
  config.before(:each) do |e|

    if e.metadata[:dynamo_db]
      pid = `docker ps | grep shim_dynamodb | awk '{print $1}'`.chomp
      if pid.blank?
        Process.fork do
          puts `docker run --name shim_dynamodb -p 8000:8000 dwmkerr/dynamodb`
        end
      end
    end
  end

  config.after(:each) do |e|
    if e.metadata[:dynamo_db]
      `docker kill shim_dynamodb; docker rm shim_dynamodb`
    end
  end
end
