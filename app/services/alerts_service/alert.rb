module AlertsService
  class Alert
    SERVICE_ATTRIBUTES = %i{ alert_id created_at updated_at}

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
        alert_class(alert).from_payload(alert)
      end
    end

    def self.alert_class(alert)
      return Alerts::MaxAttemptsReached if alert[:alert][:type] == 'Max Attempts Reached'
      Alerts.const_get(alert[:alert][:type].camelize)
    end

    def self.from_json(json)
      JSON.parse(json, symbolize_names: true).tap do |alert|
        return alert_class(alert).from_payload(alert)
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

    def type
      self.class.to_s.split("::").last.underscore
    end
    
    def as_json opts={}
      self.class::ALERT_ATTRIBUTES.map do |field_name| 
        [field_name, self.send(field_name)] 
      end.to_h.merge({type: self.type})
    end
  end
end