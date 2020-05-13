describe PipelineService::V2::Nouns::Score do
  include_context "stubbed_network"

  subject { described_class.new(object: noun) }

  let(:user) { ::User.create }
  let(:course) { ::Course.create }
  let(:enrollment) { ::Enrollment.create(user: user, course: course, workflow_state: "active")}
  let(:active_record_object) { ::Score.create(enrollment: enrollment, updated_at: Time.now) }

  let(:noun) { PipelineService::V2::Noun.new(active_record_object)}

  describe '#call' do
    it 'is in oneroster format' do
      expect(subject.call).to eq(
        {
          oneroster_result: {
              sourcedId: "<sourcedid of this grade>",
              status: "active | inactive | tobedeleted",
              dateLastModified: active_record_object.updated_at,
              lineitem: {
                  href: "<href to this lineitem>",
                  sourcedId: "<sourcedId of this lineitem>",
                  type: "lineitem"
              },
              student: {
                  href: "<href to this student>",
                  sourcedId: "com.instructure.canvas.users.#{enrollment.user.id}",
                  type: "user"
              },
              score: active_record_object.score,
              resultstatus: "partially graded",
              date: "<date that this grade was assigned>",
              comment: "<a comment to accompany the score>"
          }
        }
      )
    end
  end
end
