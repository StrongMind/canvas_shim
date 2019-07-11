module AlertsService
  module ImplementationErrors
    module ClassMethods
      def alert_attributes
        raise 'alert attributes must be defined in the as a class method before including payload_builder'
      end
    end

    def type
      raise 'you need to implement type in your alert'
    end
    
    def self.included base
      base.extend ClassMethods
    end
  end
end