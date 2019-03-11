module PipelineService
    module Helpers
        class AdditionalIdentifiers
            def self.call(instance:, fields:)
                return {} if instance.nil?
                
                fields.map do |field|
                    field.to_a(instance)
                end.to_h
            end
        end
    end
end