module PipelineService
  module FakeApi
    include Api
    include Rails.application.routes.url_helpers
    Rails.application.routes.default_url_options[:host] = ENV['CANVAS_DOMAIN']

    def admin
      GradesService::Account.account_admin
    end
  end
end