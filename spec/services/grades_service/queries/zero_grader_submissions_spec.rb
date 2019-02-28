describe GradesService::Queries::ZeroGraderSubmissions do
  include_context "pipeline_context"
  subject {described_class.new}

  describe '#submissions_scope' do
    it 'Will query after the course' do
      course = Course.create
      assignment = Assignment.create(course: course, due_at: 1.day.ago, workflow_state: 'published')
      submission = Submission.create(assignment: assignment,
          workflow_state: 'unsubmitted',
          score: nil,
          grade: nil,
          cached_due_date: assignment.due_at
        )

      expect(subject.query).to include(submission)
    end
  end
end
