module AlertsService
  module Mixins
    module JSONFactories
      module ClassMethods    
        def list_from_json(json)
          JSON.parse(json, symbolize_names: true).tap do |parsed|
            return parsed.map { |attributes| from_payload(attributes) }
          end
        end
  
        def from_json(json)
          JSON.parse(json, symbolize_names: true).tap do |attributes|
            return from_payload(attributes)  
          end
        end
  
        def from_payload(attributes)
          attributes.merge(attributes[:alert]).tap do |flattened|
            flattened.delete(:alert)
            return self.new((self::ALERT_ATTRIBUTES + self::SERVICE_ATTRIBUTES).map do |field_name|
              [field_name, flattened[field_name]] 
            end.to_h)
          end
        end
      end
    end
  end
end