# class TestAlert < AlertsService::Alert
#   ALERT_ATTRIBUTES = [:teacher_id]  
#   def type 
#     'test_alert'
#   end

#   def description
#     'my description'
#   end

#   def detail
#     'my detail'
#   end
# end

# describe AlertsService::Alert do
#   subject { TestAlert.new(teacher_id: 1) }

#   let(:attributes) { { alert: { teacher_id: 1, type: 'max_attempts_reached' } } }
    
#   describe '#as_json' do
#     it 'returns required attributes in json hash' do
#       expect(subject.as_json[:teacher_id]).to eq 1
#     end
    
#     it 'includes the type' do
#       expect(subject.as_json[:type]).to eq 'test_alert'
#     end

#     it 'does not include service_attributes' do
#       AlertsService::Alert::SERVICE_ATTRIBUTES.each do |attribute|
#         expect(subject.as_json[attribute]).to be_nil
#       end
#     end
    
#     it 'includes default alert attributes' do
#       AlertsService::Alert::DEFAULT_ALERT_ATTRIBUTES.each do |attribute|
#         puts attribute
#         expect(subject.as_json[attribute]).to_not be_nil
#       end
#     end
#   end
  
#   context 'factories' do
#     describe('#from_json') do
#       it 'builds_from' do
#         expect(AlertsService::Alert.from_json(attributes.to_json).teacher_id).to eq(1)
#       end
#     end

#     describe('#list_from_json') do
#       it 'builds lists from a json payload' do
#         expect(AlertsService::Alert.from_json([attributes].to_json).first.teacher_id).to eq(1)
#       end
#     end
#   end

# end

