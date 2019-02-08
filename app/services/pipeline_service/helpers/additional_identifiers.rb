module PipelineService
    module Helpers
        class AdditionalIdentifiers
            def self.call(payload:, fields:)
                return {} if payload.empty?
                
                result = {}

                fields.map do |field|
                    result[field.to_s] = payload[field.to_s]
                end

                result
            end
        end
    end
end