module AlertsService
  
    module AlertBuilder
      module ClassMethods
        def required_attributes
          raise 'required attributes must be defined in the as a class method before including payload_builder'
        end

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
            required_attributes.map { |field_name| [field_name, flattened[field_name]] }.to_h
          )
        end
      end

      def type
        raise 'you need to implement type in your alert'
      end
      
      def as_json(opts={})
        self.class.required_attributes.map { |field_name| [field_name, self.send(field_name)] }.to_h.merge({type: self.type})
      end

      def self.included base
        base.extend ClassMethods
        base.send(:attr_reader, *base.required_attributes)
      end
    end
  
end