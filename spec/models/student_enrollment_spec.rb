describe StudentEnrollment do
  before do
    ENV['PIPELINE_ENDPOINT'] = 'blah'
    ENV['PIPELINE_USER_NAME'] = 'blah'
    ENV['PIPELINE_PASSWORD'] = 'blah'
    ENV['SIS_ENROLLMENT_UPDATE_API_KEY'] = 'blah'
    ENV['SIS_ENROLLMENT_UPDATE_ENDPOINT'] = 'blah'
    ENV['SIS_UNIT_GRADE_ENDPOINT_API_KEY'] = 'blah'
    ENV['SIS_UNIT_GRADE_ENDPOINT'] = 'blah'
    allow(SettingsService).to receive(:get_settings).and_return({'enable_unit_grade_calculations' => true})    
    allow(PipelineService::HTTPClient).to receive(:post)
    allow(PipelineService::HTTPClient).to receive(:get).and_return(double('response', parsed_response: ''))
    allow(PipelineService::Events::HTTPClient).to receive(:post)
    allow(HTTParty).to receive(:post)
  end

  let(:assignment) { Assignment.create }
  let(:course) { Course.create(assignments: [assignment]) }
  let(:command) { double("Command", perform: nil) }
  let(:user) { User.create }

  it 'publishes pipeline events' do
    expect(PipelineService::Events::HTTPClient).to receive(:post).exactly(2).times
    described_class.create(course: course, user: user)
  end
end
