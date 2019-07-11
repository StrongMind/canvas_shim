module AlertsService
  class Alert
    SERVICE_ATTRIBUTES = %i{ alert_id created_at updated_at type }

    def initialize(atts={})
      self.class.all_fields.each do |attribute|
        self.class.send(:attr_reader, attribute) unless respond_to?(attribute)
        instance_variable_set("@#{attribute}", atts[attribute])
      end
            
      @created_at = DateTime.parse(atts[:created_at]) if atts[:created_at]
      @updated_at = DateTime.parse(atts[:updated_at]) if atts[:updated_at]
    end

    def self.list_from_json(json)
      JSON.parse(json, symbolize_names: true).map do |alert|
        alert_class = Alerts.const_get(alert[:alert][:type].camelize)
        alert_class.from_payload(alert)
      end
    end

    def self.from_json(json)
      JSON.parse(json, symbolize_names: true).tap do |alert|
        alert_class = Alerts.const_get(alert[:alert][:type].camelize)
        return alert_class.from_payload(alert)
      end
    end

    def self.all_fields
      self::ALERT_ATTRIBUTES + self::SERVICE_ATTRIBUTES
    end

    def self.from_payload(attributes)          
      new(
        all_fields.map do |field_name|
          [field_name, attributes.merge(attributes[:alert])[field_name]] 
        end.to_h
      )
    end
    
    def as_json opts={}
      self.class::ALERT_ATTRIBUTES.map do |field_name| 
        [field_name, self.send(field_name)] 
      end.to_h.merge({type: self.class::TYPE})
    end
  end
end