describe ContextModule do
  include_context 'stubbed_network'
  
  describe "#assign_threshold" do
    let(:course) do
      FactoryBot.create(:course)
    end

    let(:content_tags) do
      FactoryBot.create_list(:content_tag, 3, :with_assignment, context_id: course.id, context_type: "Course")
    end


    let(:completion_requirements) do
      content_tags[0].content.assignment_group.update(name: "workbooks")
      content_tags[1].content.assignment_group.update(name: "exams")
      content_tags[2].content.assignment_group.update(name: "assignment")
      [
        {:id=>content_tags[0].id, :type=>"must_view"},
        {:id=>content_tags[1].id, :type=>"must_submit"},
        {:id=>content_tags[2].id, :type=>"must_contribute"}
      ]
    end

    let(:course_settings) do
      {
        "assignment_passing_threshold"=>60, 
        "checkpoint_passing_threshold"=>60, 
        "close_reading_project_passing_threshold"=>60, 
        "discussion_passing_threshold"=>60, 
        "exam_passing_threshold"=>60, 
        "final_exam_passing_threshold"=>60, 
        "pretest_passing_threshold"=>60, 
        "project_passing_threshold"=>60, 
        "workbook_passing_threshold"=>60
      }
    end

    let(:threshold_overides) do 
      course_settings.merge("threshold_overrides"=>content_tags[1].id.to_s) #to_s because values in dynamodb are comma-delimited string of IDs
    end

    context "school threshold default" do
      before do
        allow(SettingsService).to receive(:get_settings).and_return(course_settings)
        ContextModule.create(completion_requirements: completion_requirements)
      end

      it "modifies submittable types" do
        requirement_types = ContextModule.last.completion_requirements.map { |req| req[:type] }
        expect(requirement_types).to_not include "must_submit"
        expect(requirement_types).to_not include "must_contribute"
      end

      it "sets min scores" do
        req_scores = ContextModule.last.completion_requirements.select { |req| req[:min_score] }.map { |req| req[:min_score] }
        expect(req_scores.any? && req_scores.all? { |score| score == 60.0 }).to be true
      end

      it "does not receive add_min_score once all have min_score" do
        expect(ContextModule.last).to_not receive(:add_min_score_to_requirements)
        ContextModule.last.save
      end

      context "no threshold score available" do
        before do
          allow_any_instance_of(RequirementsService::Commands::ApplyAssignmentGroupMinScores).to receive(:score_threshold).and_return(0.0)
          allow_any_instance_of(RequirementsService::Commands::ApplyAssignmentGroupMinScores).to receive(:has_threshold_override?).and_return(false)
          ContextModule.create(completion_requirements: completion_requirements)
        end

        it "does not modify the completion requirements" do
          expect(ContextModule.last.completion_requirements).to eq(completion_requirements)
        end
      end

      context "has threshold overrides" do
        before do
          allow(SettingsService).to receive(:get_settings).and_return(threshold_overides)
          ContextModule.create(completion_requirements: completion_requirements, course: course)
        end

        it "ignores the overridden requirement" do
          expect(ContextModule.last.completion_requirements[1][:type]).to eq("must_submit")
        end

        it "runs the rest" do
          expect(ContextModule.last.completion_requirements[2][:min_score]).to eq(60.0)
        end
      end

      context "requirements taken from previous course" do
        let(:completion_requirements) do
          content_tags[0].content.assignment_group.update(name: "workbooks")
          content_tags[1].content.assignment_group.update(name: "exams")
          content_tags[2].content.assignment_group.update(name: "assignment")
          [
            {:id=>content_tags[0].id, :type=>"min_score", min_score: 70.0},
            {:id=>content_tags[1].id, :type=>"min_score", min_score: 70.0},
            {:id=>content_tags[2].id, :type=>"min_score", min_score: 70.0}
          ]
        end

        before do
          allow_any_instance_of(RequirementsService::Commands::ApplyAssignmentGroupMinScores).to receive(:score_threshold).and_return(60.0)
          ContextModule.create(completion_requirements: completion_requirements, course: course)
        end

        it "overrides with actual threshold" do
          req_scores = ContextModule.last.completion_requirements.select { |req| req[:min_score] }.map { |req| req[:min_score] }
          expect(req_scores.all? { |score| score == 60.0 }).to be true
        end
      end
    end

    context "Course has overridden school threshold" do
      before do
        allow(SettingsService).to receive(:get_settings).and_return(course_settings)
        allow_any_instance_of(RequirementsService::Commands::ApplyAssignmentGroupMinScores).to receive(:score_threshold).and_return(70.0)
        ContextModule.create(completion_requirements: completion_requirements, course: course)
      end

      it "uses the course score threshold" do
        req_scores = ContextModule.last.completion_requirements.select { |req| req[:min_score] }.map { |req| req[:min_score] }
        expect(req_scores.any? && req_scores.all? { |score| score == 70.0 }).to be true
      end
    end
  end

  context 'callbacks' do
    describe 'before_commit' do
      let!(:context_module) { ContextModule.create }
      it 'publishes to the pipeline, with an alias' do
        expect(PipelineService).to receive(:publish_as_v2).with(context_module, alias: 'module')
        context_module.update(context_id: 54)
      end
    end
  end
end
