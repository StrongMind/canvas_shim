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
        allow_any_instance_of(ContextModule).to receive(:score_threshold).and_return(60.0)
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
          allow_any_instance_of(ContextModule).to receive(:score_threshold).and_return(0.0)
          ContextModule.create(completion_requirements: completion_requirements)
        end

        it "does not modify the completion requirements" do
          expect(ContextModule.last.completion_requirements).to eq(completion_requirements)
        end
      end

      context "new object" do
        let(:new_cm) { ContextModule.new(completion_requirements: completion_requirements) }

        it "Receives add_min_score when setting is on" do
          expect(new_cm).to receive(:add_min_score_to_requirements)
          new_cm.save
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
          allow_any_instance_of(ContextModule).to receive(:score_threshold).and_return(60.0)
          ContextModule.create(completion_requirements: completion_requirements)
        end

        it "overrides with actual threshold" do
          req_scores = ContextModule.last.completion_requirements.select { |req| req[:min_score] }.map { |req| req[:min_score] }
          expect(req_scores.all? { |score| score == 60.0 }).to be true
        end
      end
    end

    context "Course has overridden school threshold" do
      before do
        allow_any_instance_of(ContextModule).to receive(:course_score_threshold?).and_return(70.0)
        ContextModule.create(completion_requirements: completion_requirements)
      end

      it "uses the course score threshold" do
        req_scores = ContextModule.last.completion_requirements.select { |req| req[:min_score] }.map { |req| req[:min_score] }
        expect(req_scores.any? && req_scores.all? { |score| score == 70.0 }).to be true
      end
    end
  end

  describe "#force_min_score_to_requirements" do
    let(:completion_requirements) do
      [
        {:id=>53, :type=>"must_view"},
        {:id=>56, :type=>"must_submit"},
        {:id=>58, :type=>"must_contribute"}
      ]
    end

    before do
      allow_any_instance_of(ContextModule).to receive(:course_score_threshold?).and_return(70.0)
      ContextModule.create(completion_requirements: completion_requirements)
    end

    it "has 70 to start" do
      req_scores = ContextModule.last.completion_requirements.select { |req| req[:min_score] }.map { |req| req[:min_score] }
      expect(req_scores.any? && req_scores.all? { |score| score == 70.0 }).to be true
    end

    context "new threshold enforced" do
      before do
        allow_any_instance_of(ContextModule).to receive(:course_score_threshold?).and_return(75.0)
      end

      it "uses the new threshold" do
        ContextModule.last.force_min_score_to_requirements
        req_scores = ContextModule.last.completion_requirements.select { |req| req[:min_score] }.map { |req| req[:min_score] }
        expect(req_scores.any? && req_scores.all? { |score| score == 75.0 }).to be true
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
