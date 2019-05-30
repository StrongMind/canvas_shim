describe PipelineService::Builders::CourseProgressJSONBuilder do
  subject { described_class }

  include_context('stubbed_network')
  let(:course) {Course.create}
  let(:user) {User.create}
  let(:context_module) { double('course_module', context: course) }

  let(:ar_object) { double('context_module_progression', context_module: context_module, user: user, class: double(primary_key: 'id'), id: 1) }
  let(:noun) { PipelineService::Nouns::CourseProgress.new(ar_object) }

  it "Returns course progress" do
      Timecop.freeze
      expect(subject.call(noun)).to include(
        :completed_at => Time.now,
        :next_requirement_url => "http://someurl.com",
        :requirement_completed_count => 0,
        :requirement_count => 0
      )
      Timecop.return
  end
end
