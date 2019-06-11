# Use this code snippet in your app.
# If you need more information about configurations or implementing the sample code, visit the AWS docs:
# https://aws.amazon.com/developers/getting-started/ruby/

require 'aws-sdk-secretsmanager'
require 'base64'

module AlertsService
  module SecretManager
    def self.get_secret
      secret_name = "dev/alerts_service/api"
      region_name = "us-west-2"
      
      return(
        {
          'API_KEY' => ENV['ALERT_SERVICE_API_KEY'],
          'API_ENDPOINT' => ENV['ALERT_SERVICE_HOST']
        }
      ) if ENV['ALERT_SERVICE_API_KEY']

      client = Aws::SecretsManager::Client.new(region: region_name)

      # In this sample we only handle the specific exceptions for the 'GetSecretValue' API.
      # See https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
      # We rethrow the exception by default.
      begin
        get_secret_value_response = client.get_secret_value(secret_id: secret_name)
      rescue Aws::SecretsManager::Errors::DecryptionFailure => e
        # Secrets Manager can't decrypt the protected secret text using the provided KMS key.
        # Deal with the exception here, and/or rethrow at your discretion.
        raise
      rescue Aws::SecretsManager::Errors::InternalServiceError => e
        # An error occurred on the server side.
        # Deal with the exception here, and/or rethrow at your discretion.
        raise
      rescue Aws::SecretsManager::Errors::InvalidParameterException => e
        # You provided an invalid value for a parameter.
        # Deal with the exception here, and/or rethrow at your discretion.
        raise
      rescue Aws::SecretsManager::Errors::InvalidRequestException => e
        # You provided a parameter value that is not valid for the current state of the resource.
        # Deal with the exception here, and/or rethrow at your discretion.
        raise
      rescue Aws::SecretsManager::Errors::ResourceNotFoundException => e
        # We can't find the resource that you asked for.
        # Deal with the exception here, and/or rethrow at your discretion.
        raise
      else
        # This block is ran if there were no exceptions.

        # Decrypts secret using the associated KMS CMK.
        # Depending on whether the secret is a string or binary, one of these fields will be populated.
        if get_secret_value_response.secret_string
          secret = get_secret_value_response.secret_string
        else
          decoded_binary_secret = Base64.decode64(get_secret_value_response.secret_binary)
        end

        JSON.parse(secret)

        # Your code goes here.
      end
    end
  end
end