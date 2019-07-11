module AlertsService
  module AlertBuilder
    SERVICE_ATTRIBUTES = %i{ alert_id created_at updated_at type }
    include Mixins::Initializer

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

    def as_json opts={}
      self.class::ALERT_ATTRIBUTES.map do |field_name| 
        [field_name, self.send(field_name)] 
      end.to_h.merge({type: self.class::TYPE})
    end

    def self.included base
      raise 'alert attributes must be defined in the as a class method before including PayloadBuilder' unless base.const_defined?(:ALERT_ATTRIBUTES)
      raise 'you need to implement #type in your alert' unless base.const_defined?(:TYPE)
      base.extend ClassMethods
      base.send(:attr_reader, *base::ALERT_ATTRIBUTES + SERVICE_ATTRIBUTES)
    end
  end
end