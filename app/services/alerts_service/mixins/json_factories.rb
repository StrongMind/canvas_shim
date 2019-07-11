module AlertsService
  module Mixins
    module JSONFactories
      module ClassMethods
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