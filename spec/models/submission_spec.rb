describe Submission do
  context 'callbacks' do
    before do
      allow(PipelineService).to receive(:publish)
      allow(PipelineService::V2).to receive(:publish)
    end


    context "V1 Submissions" do
      describe '#send_submission_to_pipeline' do
        before do
          allow(SettingsService).to receive(:get_settings).and_return('enable_unit_grade_calculations' => false)
        end

        it 'publishes on create' do
          expect(PipelineService).to receive(:publish).with an_instance_of(Submission)
          Submission.create
        end

        it 'publishes on save' do
          s = Submission.create
          expect(PipelineService).to receive(:publish).with an_instance_of(Submission)
          s.save
        end
      end
    end

    context "V2 Submissions" do
      describe '#send_submission_to_pipeline' do
        before do
          allow(SettingsService).to receive(:get_settings).and_return({
              'enable_unit_grade_calculations' => false,
              'v2_submissions' => true
            })

        end

        it 'publishes on create' do
          expect(PipelineService::V2).to receive(:publish).with an_instance_of(Submission)
          Submission.create
        end

        it 'publishes on save' do
          s = Submission.create
          expect(PipelineService::V2).to receive(:publish).with an_instance_of(Submission)
          s.save
        end
      end
    end



  end
end
