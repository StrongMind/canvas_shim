module AlertsService
  class Alert
    # Servicd attributes are managed by the microservice and not sent in the json blob
    SERVICE_ATTRIBUTES = %i{ alert_id created_at updated_at}
    DEFAULT_ALERT_ATTRIBUTES = [:description, :detail]

    def initialize(atts={})
      self.class.all_fields.each do |attribute|
        self.class.send(:attr_reader, attribute) unless respond_to?(attribute)
        instance_variable_set("@#{attribute}", atts[attribute])
      end

      @created_at = DateTime.parse(atts[:created_at]) if atts[:created_at]
      @updated_at = DateTime.parse(atts[:updated_at]) if atts[:updated_at]
    end

    def self.list_from_json(list)
      list.map do |alert|
        if alert != nil
          alert_class(alert).from_payload(alert)
        end
      end
    end

    def self.alert_class(alert)
      begin
        Alerts.const_get(alert[:alert][:type].camelize)
      rescue => error
        puts error.message
      end
    end

    def self.from_json(json)
      payload = JSON.parse(json, symbolize_names: true)
      case payload
      when Array
        self.list_from_json(payload)
      else
        payload.tap do |alert|
          if alert == nil
            return {}
          end
          return alert_class(alert).from_payload(alert) if alert_class(alert)
        end
      end
    end

    def self.all_fields
      self::ALERT_ATTRIBUTES + self::SERVICE_ATTRIBUTES + DEFAULT_ALERT_ATTRIBUTES
    end

    def self.from_payload(attributes)
      new(
        all_fields.map do |field_name|
          [field_name, attributes.merge(attributes[:alert])[field_name]]
        end.to_h
      )
    end

    def description
      raise 'Alerts must define #description!'
    end

    def detail
      raise 'Alerts must define #detail'
    end

    def type
      self.class.to_s.split("::").last.underscore
    end

    def as_json opts={}
      (self.class::ALERT_ATTRIBUTES + DEFAULT_ALERT_ATTRIBUTES).map  do |field_name|
        [field_name, self.send(field_name)]
      end.to_h.merge({type: self.type})
    end
  end
end
