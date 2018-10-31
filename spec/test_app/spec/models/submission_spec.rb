describe Submission do
  context 'callbacks' do
    describe '#send_unit_grades_to_pipeline' do
      before do
        allow(SettingsService).to receive(:get_settings).and_return({})
        ENV['PIPELINE_ENDPOINT'] = 'endpoint'
        ENV['PIPELINE_USER_NAME'] = 'name'
        ENV['PIPELINE_PASSWORD'] = 'password'
        allow(PipelineService::HTTPClient).to receive(:post)
      end

      it 'actually happens' do
        assignment = Assignment.create
        user = User.create
        content_tag = ContentTag.create(content: assignment)
        context_module = ContextModule.create(content_tags: [content_tag])
        course = Course.create(context_modules: [context_module])

        assignment = Assignment.create(course: course)

        s = Submission.create(user: user, assignment: assignment)

        expect(PipelineService::HTTPClient).to receive(:post).with(hash_including(data: {}))
        s.update(score: 50)
      end
    end
  end
end
