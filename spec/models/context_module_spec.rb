describe ContextModule do
  include_context 'stubbed_network'
  
  describe "#assign_threshold" do
    let(:completion_requirements) do
      [
        {:id=>53, :type=>"must_view"},
        {:id=>56, :type=>"must_submit"},
        {:id=>58, :type=>"must_contribute"}
      ]
    end

    context "school threshold default" do
      before do
        allow_any_instance_of(RequirementsService::Commands::ApplyMinimumScores).to receive(:score_threshold).and_return(60.0)
        allow_any_instance_of(RequirementsService::Commands::ApplyMinimumScores).to receive(:has_threshold_override?).and_return(false)
        ContextModule.create(completion_requirements: completion_requirements)
      end

      it "modifies submittable types" do
        req_types = ContextModule.last.completion_requirements.map { |req| req[:type] }
        expect(req_types).to_not include "must_submit"
        expect(req_types).to_not include "must_contribute"
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
          allow_any_instance_of(RequirementsService::Commands::ApplyMinimumScores).to receive(:score_threshold).and_return(0.0)
          allow_any_instance_of(RequirementsService::Commands::ApplyMinimumScores).to receive(:has_threshold_override?).and_return(false)
          ContextModule.create(completion_requirements: completion_requirements)
        end

        it "does not modify the completion requirements" do
          expect(ContextModule.last.completion_requirements).to eq(completion_requirements)
        end
      end


      context "has threshold overrides" do
        before do
          allow_any_instance_of(RequirementsService::Commands::ApplyMinimumScores).to receive(:has_threshold_override?).with({:id=>56, :type=>"must_submit"}).and_return(true)
          ContextModule.create(completion_requirements: completion_requirements, course: Course.create)
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
          [
            {:id=>53, :type=>"min_score", min_score: 70.0},
            {:id=>56, :type=>"min_score", min_score: 70.0},
            {:id=>58, :type=>"min_score", min_score: 70.0}
          ]
        end

        before do
          allow_any_instance_of(RequirementsService::Commands::ApplyMinimumScores).to receive(:score_threshold).and_return(60.0)
          ContextModule.create(completion_requirements: completion_requirements, course: Course.create)
        end

        it "overrides with actual threshold" do
          req_scores = ContextModule.last.completion_requirements.select { |req| req[:min_score] }.map { |req| req[:min_score] }
          expect(req_scores.all? { |score| score == 60.0 }).to be true
        end
      end
    end

    context "Course has overridden school threshold" do
      before do
        allow_any_instance_of(RequirementsService::Commands::ApplyMinimumScores).to receive(:score_threshold).and_return(70.0)
        ContextModule.create(completion_requirements: completion_requirements, course: Course.create)
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
        expect(PipelineService).to receive(:publish).with(context_module, alias: 'module')
        context_module.update(context_id: 54)
      end
    end
  end
end
