module AlertsService
  Response = Struct.new(:code, :payload)

  School = Struct.new(:name) do
    def id
      Base64.urlsafe_encode64(name)
    end
  end
end