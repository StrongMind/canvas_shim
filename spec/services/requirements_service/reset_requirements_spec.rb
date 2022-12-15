describe RequirementsService::Commands::ResetRequirements do
  include_context 'stubbed_network'
  let(:subject) { described_class.new(context_module: context_module, assignment_group_name: content_tags[1].content.passing_threshold_group_name) }
  
  let(:subject_2) { described_class.new(context_module: context_module, assignment_group_name: content_tags[3].content.assignment.passing_threshold_group_name) }
  
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

  let(:content_tags) do
    tags = FactoryBot.create_list(:content_tag, 3, :with_assignment, context_id: course.id, context_type: "course")
    tags << FactoryBot.create(:content_tag, :with_discussion_topic, context_id: course.id, context_type: 'course')
  end

  let(:completion_requirements) do
    content_tags[0].content.assignment_group.update(name: "workbooks")
    content_tags[1].content.assignment_group.update(name: "exams")
    content_tags[2].content.assignment_group.update(name: "assignment")
    content_tags[3].content.assignment.assignment_group.update(name: "discussion")
    [
      {:id=>content_tags[0].id, :type=>"must_view"},
      {:id=>content_tags[1].id, :type=>"must_submit"},
      {:id=>content_tags[2].id, :type=>"must_contribute"},
      {:id=>content_tags[3].id, :type=>"min_score", :min_score=>69.0}
    ]
  end

  describe "#call" do
    it "converts to a must_submit" do
      subject.call
      expect(context_module.completion_requirements[1][:type]).to eq("must_submit")
    end

    context "DiscussionTopic" do
      before do
        content_tags[3].update(content_type: "DiscussionTopic")
      end

      it "Turns to a must contribute when content_type is DiscussionTopic" do
        subject_2.call
        expect(context_module.completion_requirements[3][:type]).to eq("must_contribute")
      end
    end
  end
end