describe Submission do
  context 'callbacks' do
    describe '#send_unit_grades_to_pipeline' do
      before do
        allow(SettingsService).to receive(:get_settings).and_return({})
        ENV['PIPELINE_ENDPOINT'] = 'endpoint'
        ENV['PIPELINE_USER_NAME'] = 'name'
        ENV['PIPELINE_PASSWORD'] = 'password'
        ENV['SIS_ENROLLMENT_UPDATE_API_KEY'] = 'junk'
        ENV['SIS_ENROLLMENT_UPDATE_ENDPOINT'] = 'junk'
        ENV['SIS_UNIT_GRADE_ENDPOINT_API_KEY'] = 'hunk'
        ENV['SIS_UNIT_GRADE_ENDPOINT'] = 'junk'

        allow(PipelineService::HTTPClient).to receive(:post)
        allow(PipelineService::Events::HTTPClient).to receive(:post)
        assignment.update(course: course)
      end

      let(:assignment) {Assignment.create}
      let(:user) {User.create}
      let(:content_tag) {ContentTag.create(content: assignment)}
      let(:context_module) {ContextModule.create(content_tags: [content_tag])}
      let(:course) {Course.create(context_modules: [context_module])}
      let(:data_result) {{submitted_at: nil, :course_id => course.id, :school_domain => nil, :student_id => user.id, :units => []}}


      it 'posts unit grades to the pipeline' do
        expect(PipelineService::HTTPClient).to receive(:post).with(
            hash_including(data: data_result, noun: 'unit_grades')
        )
        Submission.create(user: user, assignment: assignment, score: 50)
      end

      it 'sends an event to SIS with the unit grade' do
        expect(PipelineService::Events::HTTPClient).to receive(:post)
        Submission.create(user: user, assignment: assignment, score: 50)
      end

      it 'wont send if there is no change to the score' do
        expect(PipelineService::Events::HTTPClient).to_not receive(:post)
        Submission.create(user: user, assignment: assignment)
      end
    end
  end
end
