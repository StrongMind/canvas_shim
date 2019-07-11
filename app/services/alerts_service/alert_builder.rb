module AlertsService
  module AlertBuilder
    include ImplementationErrors
    include ServiceAttributes
    
    module ClassMethods    
      # Return a list of alerts from json
      def list_from_json(json)
        JSON.parse(json, symbolize_names: true).tap do |parsed|
          return parsed.map do |attributes|
            from_payload_attributes(attributes)
          end
        end
      end

      # Return a single alert from json
      def from_json(json)
        JSON.parse(json, symbolize_names: true).tap do |attributes|
          return from_payload_attributes(attributes)  
        end
      end

      # Return an instance by pulling the required attributes 
      # from a hash
      def from_payload_attributes(attributes)
        flattened = attributes.merge(attributes[:alert])
        flattened.delete(:alert)
        new(
          (alert_attributes + ServiceAttributes::SERVICE_ATTRIBUTES).map do |field_name| 
            [field_name, flattened[field_name]] 
          end.to_h
        )
      end
    end

    def builder_initialize(atts={})
      (self.class.alert_attributes + ServiceAttributes::SERVICE_ATTRIBUTES).each do |attribute|
        instance_variable_set("@#{attribute}", atts[attribute])
      end
      alert_initialize(atts)
    end

    def as_json(opts={})
      self.class.alert_attributes.map do |field_name| 
        [field_name, self.send(field_name)] 
      end.to_h.merge({type: type})
    end

    def initialize(atts)
      # place holder in case no initialize is defined on base
    end

    def self.included base
      raise 'alert attributes must be defined in the as a class method before including PayloadBuilder' unless base.methods.include? :alert_attributes
      raise 'you need to implement #type in your alert' unless base.method_defined?(:type)
      base.extend ClassMethods
      
      # Make alert attributes readable
      base.send(:attr_reader, *base.alert_attributes)
      
      # Our initializer sets all the alert fields and service fields, then
      # calls the alert initializer in case the implementer wants to do anything else
      base.send(:alias_method, :alert_initialize, :initialize)
      base.send(:alias_method, :initialize, :builder_initialize)
    end
  end
end