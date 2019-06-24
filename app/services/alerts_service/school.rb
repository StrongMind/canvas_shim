module AlertsService
  class School
    attr_reader :name
    def initialize(name)
      @name = name
    end

    def id
      Base64.urlsafe_encode64(name, padding: false)
    end
  end
end