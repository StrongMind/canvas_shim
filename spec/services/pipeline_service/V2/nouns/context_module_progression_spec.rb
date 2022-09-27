describe PipelineService::V2::Nouns::ContextModuleProgression do
  include_context "stubbed_network"

  subject { described_class.new(object: noun) }

  let!(:user) { ::User.create }
  let!(:course) { ::Course.create }
  let!(:enrollment) { ::Enrollment.create(user: user, course: course, type: 'StudentEnrollment')}
  let!(:cm) { ::ContextModule.create(context_id: course.id, context_type: 'Course') }
  let!(:active_record_object) { ::ContextModuleProgression.create(user: user, context_module: cm) }
  let!(:noun) { PipelineService::V2::Noun.new(active_record_object)}

  describe '#call'do
    it 'returns with context module progression' do
      expect(subject.call).to eq({
        "id" => active_record_object.id,
        "user_id" => user.id,
        "context_module_id" => cm.id,
        "collapsed" => nil,
        "lock_version" => 0
      })
    end
  end
end
