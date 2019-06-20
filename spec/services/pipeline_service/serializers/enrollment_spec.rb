describe PipelineService::Serializers::Enrollment do
  let(:noun) {double('noun', id: 1)}

  let(:enrollment) { double('enrollment')}

  let(:subject) {
    described_class.new(object: noun)
  }
  
  let(:result) do 
    {
      "grades" => {
        "html_url" => "",
        "current_score" => 0,
        "current_grade" => nil,
        "final_score" => 0,
        "final_grade" => nil
      }  
    }
  end

  before do
    allow(::Enrollment).to receive(:find).and_return(enrollment)
    allow(PipelineService::Serializers::Enrollment).to receive(:new).and_return(
      subject
    )
    allow(subject).to receive(:enrollment_json).and_return(result)
  end

  describe '#additional_identifier_fields' do
    it 'has a course_id and an user_id' do 
      expect(described_class.additional_identifier_fields.map(&:to_h)).to eq [{:course_id=>nil}, {:user_id=>nil}]
    end
  end

  describe '#call' do
    it 'sets scores to 0 if they are nil' do
      expect(subject.call['grades']["current_grade"]).to eq(0)
    end
  end
end