module AlertsService
  module Mixins
    module JSONFactories
      module ClassMethods    
        def list_from_json(json)
          JSON.parse(json, symbolize_names: true).map do |attributes| 
            from_payload attributes
          end
        end
  
        def from_json(json)
          from_payload JSON.parse(json, symbolize_names: true)
        end

        private

        def all_fields
          self::ALERT_ATTRIBUTES + self::SERVICE_ATTRIBUTES
        end
  
        def from_payload(attributes)          
          new(
            all_fields.map do |field_name|
              [field_name, attributes.merge(attributes[:alert])[field_name]] 
            end.to_h
          )
        end
      end
    end
  end
end