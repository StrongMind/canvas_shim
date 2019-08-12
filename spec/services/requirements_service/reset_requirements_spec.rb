describe RequirementsService::Commands::ResetRequirements do
  include_context 'stubbed_network'
  subject { described_class.new(context_module: context_module) }
  
  let(:subject_2) { described_class.new(context_module: context_module, exam: true) }
  
  let(:course) { double('course', id: 1) }
  
  let(:context_module) do 
    double(
      'context module', 
      completion_requirements: completion_requirements,
      course: course,
      update_column: nil,
      touch: nil,
    ) 
  end

  let(:completion_requirements) do
    [
      {:id=>53, :type=>"must_view"},
      {:id=>56, :type=>"min_score", :min_score => 70},
      unit_exam
    ]
  end

  let(:unit_exam) do
    {:id=>58, :type=>"min_score", :min_score => 75}
  end

  before do
    ContentTag.create(id: 56)
    allow(subject).to receive(:unit_exam?).and_call_original
    allow(subject).to receive(:unit_exam?).with(unit_exam).and_return(true)
  end

  describe "#call" do
    it "skips the unit exam" do
      subject.call
      req_scores = context_module.completion_requirements.select { |req| req[:min_score] }
      expect(req_scores.size).to eq(1)
      expect(req_scores.first[:min_score]).to eq(75)
    end

    it "converts to a must_submit" do
      subject.call
      expect(context_module.completion_requirements[1][:type]).to eq("must_submit")
    end

    
    context "DiscussionTopic" do
      before do
        ContentTag.find(56).update(content_type: "DiscussionTopic")
      end

      it "Turns to a must contribute when content_type is DiscussionTopic" do
        subject.call
        expect(context_module.completion_requirements[1][:type]).to eq("must_contribute")
      end
    end

    context "Unit Exam" do
      before do
        content_tag = ContentTag.create(id: 58)
        allow(RequirementsService).to receive(:is_unit_exam?).and_call_original
        allow(RequirementsService).to receive(:is_unit_exam?).with(content_tag: content_tag).and_return(true)
      end

      it "converts the unit exam" do
        subject_2.call
        expect(context_module.completion_requirements[2][:type]).to eq("must_submit")
      end
    end
  end
end