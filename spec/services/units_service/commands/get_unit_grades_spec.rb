describe UnitsService::Commands::GetUnitGrades do
  include_context "stubbed_network"
  let(:course) { Course.create(assignment_groups: []) }
  let(:pseudonym) { Pseudonym.create(sis_user_id: 1001) }
  let(:user) { User.create(pseudonym: pseudonym) }
  let(:query_instance) { double('query instance', query: nil) }
  let(:current_time) { Time.now.in_time_zone('UTC') }
  let(:calculator_instance) { double('calculator_instance', call: { cm => 54}) }
  let(:submitted_at) { Time.now }
  let(:submission) { double('submission', submitted_at: submitted_at, graded_at: current_time, grader_id: 2) }
  let(:cm) {ContextModule.create(position: 3)}
  let(:unit_submissions) { Hash.new }

  subject { described_class.new(course: course, student: user, submission: submission) }

  before do
    allow(SettingsService).to receive(:get_settings).and_return('auto_due_dates' => nil, 'auto_enrollment_due_dates' => nil)
    @enrollment = Enrollment.create(user: user, course: course)
    ENV['CANVAS_DOMAIN'] = 'canvasdomain.com'
    allow(UnitsService::Queries::GetSubmissions).to receive(:new).and_return(query_instance)
    allow(UnitsService::GradesCalculator).to receive(:new).and_return(calculator_instance)
    allow(UnitsService::Queries::GetEnrollment).to receive(:query).and_return(@enrollment)
    allow(@enrollment).to receive(:computed_current_score).and_return(90)
    allow(subject).to receive(:unit_submissions).and_return(unit_submissions)
    allow(submission).to receive(:excused?).and_return(false)

    # needed for admin check in GetUnitGrades#submissions_graded?
    allow(GradesService::Account).to receive_message_chain(:account_admin, :id).and_return 1
  end


  it 'returns the calculator results' do
    unit_submissions[cm] = [submission]
    expect(subject.call).to eq(
      course_id: course.id,
      course_score: 90,
      school_domain: "canvasdomain.com",
      student_id: user.id,
      sis_user_id: "1001",
      submitted_at: submitted_at,
      units: [{
        score: 54,
        id: cm.id,
        position: cm.position,
        excused: false
      }]
    )
  end

  describe "#submissions_graded?" do
    it "returns the score" do
      unit_submissions[cm] = [Submission.create(graded_at: current_time, grader_id: 2)]
      expect(subject.send(:submissions_graded?, cm, 54)).to eq 54
    end

    context "student has no graded submissions" do
      it 'returns nil if no score' do
        unit_submissions[cm] = [Submission.create]
        expect(subject.send(:submissions_graded?, cm, 0)).to eq nil
      end
    end

    context "student has graded submissions from zerograder" do
      it 'returns nil with zerograded submissions' do
        unit_submissions[cm] = [Submission.create(score: 0, graded_at: current_time, grader_id: 1)]
        expect(subject.send(:submissions_graded?, cm, 0)).to eq nil
      end
    end
  end

  context "#unit_excused?" do
    let!(:course) {Course.create()}
    let!(:cm) {ContextModule.create(position: 3, course: course)}
    let!(:assignment) { create(:assignment, :with_assignment_group, workflow_state: 'active', course: course)}
    let!(:content_tag) { ContentTag.create(context_module: cm, assignment: assignment, content_type: 'Assignment', content_id: assignment.id) }
    let!(:submission) { Submission.create(grader_id: 2, submitted_at: current_time, user: user, assignment: assignment) }

    before do
      allow(submission).to receive(:excused?).and_return(true)
      submission.update(excused: true)
    end

    it 'returns true if all are excused' do
      expect(subject.send(:unit_excused?, cm)).to eq true
    end

    it 'returns false if not all are excused' do
      cm = ContextModule.create()
      assignment = create(:assignment, :with_assignment_group, workflow_state: 'active')
      assignment_2 = create(:assignment, :with_assignment_group, workflow_state: 'active')

      content_tag = ContentTag.create(context_module: cm, assignment: assignment, content_type: 'Assignment', content_id: assignment.id)
      content_tag_2 = ContentTag.create(context_module: cm, assignment: assignment_2, content_type: 'Assignment', content_id: assignment.id)

      submission = Submission.create(grader_id: 2, submitted_at: current_time, user: user, assignment: assignment)
      submission_2 = Submission.create(grader_id: 2, submitted_at: current_time, user: user, assignment: assignment_2)
      submission_2.update(excused: true)
      expect(subject.send(:unit_excused?, cm)).to eq false
    end

    it 'returns the excused calculator results' do
      allow(subject).to receive(:calculate_grades).and_return([])
      subject.instance_variable_set(:@grades, [])
      unit_submissions[cm] = [Submission.create()]
      expect(subject.call).to eq(
        course_id: course.id,
        course_score: 90,
        school_domain: "canvasdomain.com",
        student_id: user.id,
        sis_user_id: "1001",
        submitted_at: current_time,
        units: [{
          score: nil,
          id: cm.id,
          position: cm.position,
          excused: true
        }]
      )
    end
  end
end
