module PipelineService
  class TokenBuilder
    include Singleton

    def self.build
      instance.build
    end

    def build
      return token if token
      delete_existing
      create
      cache
      token
    end

    private

    attr_reader :token

    def delete_existing
      AccessToken.where(purpose: 'Pipeline API Access').delete_all
    end

    def account_admin
      PipelineService::Account.account_admin
    end

    def create
      @token = Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          account_admin.access_tokens.create(
            developer_key: DeveloperKey.default,
            purpose: 'Pipeline API Access'
          )
        end
      end.value.full_token
    end

    def cache
      Canvas.redis.set('PIPELINE_CANVAS_API_TOKEN', token)
    end

    def token
      @token ||= Canvas.redis.get('PIPELINE_CANVAS_API_TOKEN')
    end
  end
end
