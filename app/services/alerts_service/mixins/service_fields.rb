module AlertsService
  module Mixins
    module ServiceFields
      def created_at
        DateTime.parse(@created_at)
      end

      def updated_at
        DateTime.parse(@updated_at)
      end

      def alert_id
        @alert_id
      end
    end  
  end
end