describe PipelineService::Builders::CourseProgressJSONBuilder do
  subject { described_class }

  include_context('stubbed_network')
  let(:course) {Course.create}
  let(:user) {User.create}

  let(:ar_object) { double('context_module_progression', course: course, user: user) }
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
