describe UnitsService::Queries::GetSubmissions do
  before do
    @student = Student.create
    @course = Course.create
  end

  # let(:query_result) do
  #   result = {}
  #   result[context_module] = [content_tag]
  #   result
  # end
  #
  # let(:get_items_instance) { double('get items query', query: query_result) }
  # let(:pipeline_service) { double('pipeline service', publish: nil) }
  #
  # subject { described_class.new(student: user, course: course) }
  #
  # before do
  #   allow(UnitsService::Queries::GetItems).to receive(:new).and_return(get_items_instance)
  #   allow(Submission).to receive(:pipeline_service).and_return(pipeline_service)
  # end
  #
  # it do
  #   expect(subject.query).to eq ''
  #   # expect(subject.query).to eq course
  # end
end
