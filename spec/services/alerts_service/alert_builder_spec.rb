class TestAlert
  def self.alert_attributes
    [:teacher_id]
  end
  
  include AlertsService::AlertBuilder


  def type
    'test_alert'
  end
end

describe AlertsService::AlertBuilder do
  subject { TestAlert.new(teacher_id: 1) }

  let(:attributes) { {alert: {teacher_id: 1}} }
    
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
          expect(TestAlert.from_json(attributes.to_json).teacher_id).to eq(1)
        end
      end

      describe('#from_json_list') do
        it 'builds from a json payload' do
          expect(TestAlert.list_from_json([attributes].to_json).first.teacher_id).to eq(1)
        end
      end
    end
  end
end