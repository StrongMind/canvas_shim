describe "Playground" do
    before do
        allow(PipelineService::Events::HTTPClient).to receive(:post)
        allow(PipelineService::HTTPClient).to receive(:post)
        allow(enrollment).to receive(:changes).and_return({'workflow_state' => ['active', 'completed']})
        allow(Pandarus::Client).to receive(:new).and_return(api_client)
        
        ENV['SIS_ENROLLMENT_UPDATE_API_KEY']='enrollment_update_key'
        ENV['SIS_ENROLLMENT_UPDATE_ENDPOINT']='enrollment_update_endpoint'
        ENV['SIS_UNIT_GRADE_ENDPOINT_API_KEY']='unit_grade_key'
        ENV['SIS_UNIT_GRADE_ENDPOINT']='unit_grade_endpoint'

    end

    let(:api_client) {double('client', get_single_submission_courses: nil)}
    let!(:user) { User.create }    
    let(:enrollment) { Enrollment.create(course: course, user: user) }  
    let(:course) { Course.create }
    let(:user) { User.create(pseudonym: Pseudonym.create) }
    let(:assignment) { Assignment.create(course: course) }
    let(:submission) { Submission.create(assignment: assignment, user: user, course: course) }
    
    it 'Publishes enrollment events for SIS' do
        expect(PipelineService::Events::HTTPClient).to receive(:post).with('enrollment_update_endpoint?apiKey=enrollment_update_key', any_args)
        PipelineService.publish(enrollment)
    end

    it 'Publishes enrollment grade out events for SIS' do
        allow(submission).to receive(:changes).and_return( { 'score' => [10, 15]} )
        expect(PipelineService::Events::HTTPClient).to receive(:post).with('unit_grade_endpoint?apiKey=unit_grade_key', any_args)
        PipelineService.publish(PipelineService::Nouns::UnitGrades.new(submission))
    end
end