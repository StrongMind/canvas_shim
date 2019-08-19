describe PipelineService::Serializers::Course do
    include_context "stubbed_network"
  
    subject { described_class.new(object: noun) }
  
    let(:active_record_object) { Course.create!() }
    let(:noun) { PipelineService::Models::Noun.new(active_record_object)}

    before do
      allow(SettingsService).to receive(:get_settings).and_return({
        'passing_threshold' => 50,
        'passing_exam_threshold' => 50
      })
    end

    it 'Return an attribute hash of the noun' do
      expect(subject.call).to include({
        noun.primary_key => active_record_object.id,
        'passing_thresholds' => {
          "assignment"=>50.0,
          "exam"=>50.0
        }
      })
    end
  end