module AlertsService
  module AlertBuilder
    SERVICE_ATTRIBUTES = [:alert_id, :created_at, :updated_at]  
    include Mixins::ServiceFields
    include Mixins::JSONFactories
    include Mixins::Initializer

    def as_json(opts={})
      self.class::ALERT_ATTRIBUTES.map do |field_name| 
        [field_name, self.send(field_name)] 
      end.to_h.merge({type: self.class::TYPE})
    end

    def self.included base
      raise 'alert attributes must be defined in the as a class method before including PayloadBuilder' unless base.const_defined? :ALERT_ATTRIBUTES
      raise 'you need to implement #type in your alert' unless base.const_defined?(:TYPE)
      base.extend Mixins::JSONFactories::ClassMethods
      base.send(:attr_reader, *base::ALERT_ATTRIBUTES)
    end
  end
end