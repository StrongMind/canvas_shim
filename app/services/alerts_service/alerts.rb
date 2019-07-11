module AlertsService
  module Alerts
    def self.list_from_json(json)
      JSON.parse(json, symbolize_names: true).map do |alert|
        alert_class = const_get(alert[:alert][:type].camelize)
        alert_class.from_payload(alert)
      end
    end

    def self.from_json(json)
      JSON.parse(json, symbolize_names: true).tap do |alert|
        alert_class = const_get(alert[:alert][:type].camelize)
        return alert_class.from_payload(alert)
      end
    end
  end
end