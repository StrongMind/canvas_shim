describe ContextModule do
  include_context "stubbed_network"
  context 'callbacks' do
    describe 'before_commit' do
      let!(:context_module) { ContextModule.create }
      it 'publishes to the pipeline, with an alias' do
        expect(PipelineService).to receive(:publish).with(context_module, alias: 'module')
        context_module.update(context_id: 54)
      end
    end
  end

  context do
    before do
      allow_any_instance_of(ContextModule).to receive(:score_threshold).and_return(60.0)
    end
    
    describe "#assign_threshold" do
      let(:completion_requirements) do
        [
          {:id=>53, :type=>"must_view"},
          {:id=>56, :type=>"must_submit"},
          {:id=>58, :type=>"must_contribute"}
        ]
      end
      
      before do
        @context_module = ContextModule.create(completion_requirements: completion_requirements)
      end

      it "modifies submittable types" do
        req_types = @context_module.completion_requirements.map { |req| req[:type] }
        expect(req_types).to_not include "must_submit"
        expect(req_types).to_not include "must_contribute"
      end

      it "sets min scores" do
        req_scores = @context_module.completion_requirements.select { |req| req[:min_score] }.map { |req| req[:min_score] }
        expect(req_scores.any? && req_scores.all? { |score| score == 60.0 }).to be true
      end

      it "does not receive add_min_score once all have min_score" do
        expect(@context_module).to_not receive(:add_min_score_to_requirements)
        @context_module.save
      end

      context "no threshold score available" do
        before do
          allow_any_instance_of(ContextModule).to receive(:score_threshold).and_return(0.0)
          @context_module = ContextModule.create(completion_requirements: completion_requirements)
        end

        it "does not modify the completion requirements" do
          expect(@context_module.completion_requirements).to eq(completion_requirements)
        end
      end

      context "new object" do
        let(:new_cm) { ContextModule.new(completion_requirements: completion_requirements) }

        it "Receives add_min_score when setting is on" do
          expect(new_cm).to receive(:add_min_score_to_requirements)
          new_cm.save
        end
      end
    end
  end
end
