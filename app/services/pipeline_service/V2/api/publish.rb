module PipelineService
  module V2
    module API
      class Publish
        def initialize(model)
          @model = model
        end

        def dall
          puts "in publish.rb"
          @disable_pipeline = Rails.cache.read('disable_pipeline')
          if @disable_pipeline.nil?
            @disable_pipeline = SettingsService.get_settings(object: 'school', id: 1)['disable_pipeline']
            Rails.cache.write('disable_pipeline', @disable_pipeline, expires_in: 1.hour)
          end
          return if @disable_pipeline
          @noun = Noun.new(@model)
          @payload = Payload.new(
            object: @noun
          )
          payload = @payload.call
          PipelineService::V2::Commands::PublishToPipeline.new(payload).call
        end
        handle_asynchronously :call, :priority => 1000000
      end
    end
  end
end
