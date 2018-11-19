describe UnitsService::Queries::GetSubmissions do
  before do
    allow(PipelineService).to receive(:publish)
    seed
  end

  it 'please works' do
    # expect(true).to be_true
  end

  def seed
    course = Course.create
    user = User.create(pseudonym: Pseudonym.create)

    6.times do |count|
      assignment1 = Assignment.create(published: true)
      content_tag1 = ContentTag.create(content: assignment1)
      assignment2 = Assignment.create(published: true)
      content_tag2 = ContentTag.create(content: assignment2)

      course.context_modules << ContextModule.create(
        content_tags: [content_tag1, content_tag2]
      )
      course.assignments << assignment1
      course.assignments << assignment2
      assignment1.submissions << Submission.create(user: user, assignment: assignment1, course: course)
      assignment2.submissions << Submission.create(user: user, assignment: assignment2, course: course)
    end
    byebug
  end
end
