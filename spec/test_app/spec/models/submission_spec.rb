describe Submission do
  context 'callbacks' do
    describe '#send_unit_grades_to_pipeline' do
      before do
        allow(SettingsService).to receive(:get_settings).and_return({})
        ENV['PIPELINE_ENDPOINT'] = 'endpoint'
        ENV['PIPELINE_USER_NAME'] = 'name'
        ENV['PIPELINE_PASSWORD'] = 'password'
        allow(PipelineService::HTTPClient).to receive(:post)
        assignment.update(course: course)
      end

      let(:assignment) { Assignment.create }
      let(:user) { User.create }
      let(:content_tag) { ContentTag.create(content: assignment) }
      let(:context_module) { ContextModule.create(content_tags: [content_tag]) }
      let(:course) { Course.create(context_modules: [context_module]) }
      let(:data_result) { {}.tap {|result| result[context_module.id] = 50} }

      it 'actually happens' do
        expect(PipelineService::HTTPClient).to receive(:post).with(hash_including(data: data_result))
        submission = Submission.create(user: user, assignment: assignment, score: 50)
      end
    end
  end
end
