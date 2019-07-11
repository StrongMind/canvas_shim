class TestAlert
  ALERT_ATTRIBUTES = [:teacher_id]  
  TYPE = 'test_alert'
  include AlertsService::AlertBuilder
end

describe AlertsService::AlertBuilder do
  subject { TestAlert.new(teacher_id: 1) }

  let(:attributes) { {alert: {teacher_id: 1, type: 'max_attempts_reached'}} }
    
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
          expect(AlertsService::Alerts.from_json(attributes.to_json).teacher_id).to eq(1)
        end
      end

      describe('#from_json_list') do
        it 'builds from a json payload' do
          expect(AlertsService::Alerts.list_from_json([attributes].to_json).first.teacher_id).to eq(1)
        end
      end
    end
  end
end