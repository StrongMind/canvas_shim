describe PipelineService::Serializers::Fetcher do
  subject { described_class }
  let(:assignment) { double('object', class: 'Assignment') }

  include_context 'pipeline_context'

  describe '#fetch' do
    it 'fetches serializers based on the object #class' do
      expect(subject.fetch(object: assignment)).to eq(
        PipelineService::Serializers::Assignment
      )
    end
    
    context "Enrollments" do
      before do
        class_double("PipelineService::Serializers::Enrollment").as_stubbed_const
      end

      let(:teacher_enrollment) { double('object', class: 'TeacherEnrollment') }
      it 'publishes Teacher Enrollments as Enrollments' do
        subject.fetch(object: teacher_enrollment)
        expect(subject.fetch(object: teacher_enrollment)).to eq(
          PipelineService::Serializers::Enrollment
        )
      end

      let(:deleted_noun) { PipelineService::Models::Noun.new(TeacherEnrollment.create) }
      it 'can delete enrollments' do
        expect(subject.fetch(object: deleted_noun)).to eq(PipelineService::Serializers::Enrollment)
      end
    end
  end
end
