module AlertsService
  module Mixins
    module Initializer
      def builder_initialize(atts={})
        (self.class::ALERT_ATTRIBUTES + self.class::SERVICE_ATTRIBUTES).each do |attribute|
          instance_variable_set("@#{attribute}", atts[attribute])
        end
        alert_initialize(atts)
      end

      def initialize(atts)
        # place holder in case no initialize is defined on base
      end

      def self.included base
        # Our initializer sets all the alert fields and service fields, then
        # calls the alert initializer in case the implementer wants to do anything else
        base.send(:alias_method, :alert_initialize, :initialize)
        base.send(:alias_method, :initialize, :builder_initialize)
      end
    end
  end
end
