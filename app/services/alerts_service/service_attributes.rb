module AlertsService
  module ServiceAttributes
    SERVICE_ATTRIBUTES = [:alert_id, :created_at, :updated_at]
    
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