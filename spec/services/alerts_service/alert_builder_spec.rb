class TestAlert < AlertsService::Alert
  ALERT_ATTRIBUTES = [:teacher_id]  
  TYPE = 'test_alert'
end

describe AlertsService::Alert do
  subject { TestAlert.new(teacher_id: 1) }

  let(:attributes) { {alert: {teacher_id: 1, type: 'max_attempts_reached'}} }
  let(:alert_fields) { { alert: {techer_id: 1, type: 'max_attempts_reached'} } }
    
  describe 'as_json' do
    it 'returns required attributes in json hash' do
      expect(subject.as_json[:teacher_id]).to eq 1
    end
    
    it 'includes the type' do
      expect(subject.as_json[:type]).to eq 'test_alert'
    end

    context 'class methods' do
      describe('#from_json') do
        it 'builds_from' do
          expect(AlertsService::Alert.from_json(attributes.to_json).teacher_id).to eq(1)
        end
      end

      describe('#list_from_json') do
        it 'builds from a json payload' do
          expect(AlertsService::Alert.list_from_json([attributes].to_json).first.teacher_id).to eq(1)
        end
      end
    end
  end
end

