module PipelineService
    module Helpers
        class AdditionalIdentifiers
            def self.from_payload(payload:, fields:)
                return {} if payload.empty?
                
                result = {}

                fields.map do |field|
                    result[field.to_s] = payload[field.to_s]
                end

                result
            end
            
            def self.from_instance(instance:, fields:)
                return {} if instance.nil?
                
                fields.map do |field|
                    [field, instance.send(field.to_s)]
                end.to_h
            end
        end
    end
end