describe PipelineService::V2::Nouns::Course do
  include_context "stubbed_network"

  subject { described_class.new(object: noun) }

  let(:active_record_object) { ::Course.create }

  let(:noun) { PipelineService::V2::Noun.new(active_record_object)}

  describe '#call'do
    it 'returns with course passing threshold' do
      allow(SettingsService).to receive(:get_settings).and_return({'passing_threshold' => 50, 'passing_exam_threshold' => 50})
      expect(subject.call).to include({'passing_thresholds' => {
        'assignment' => 50,
        'exam' => 50,
        }
      })
    end
  end
end
