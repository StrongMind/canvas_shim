describe AlertsService do
  describe '#create' do
    let(:alert) do
      AlertsService::Alerts::AttemptsExceeded.new(
        student_id: 1,
        teacher_id: 1,
        assignment_id: 1,
        message: 'The student reached their max attempts for an assignment'
      )
    end
    
    it 'creates an alert' do
      AlertsService.create(alert)
    end
  end
end