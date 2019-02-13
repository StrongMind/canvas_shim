describe "Playground" do
    before do
        allow(PipelineService::Events::HTTPClient).to receive(:post)
        allow(PipelineService::HTTPClient).to receive(:post)
        allow(enrollment).to receive(:changes).and_return({'workflow_state' => ['active', 'completed']})
    end

    let!(:user) { User.create }
    
    let(:enrollment) { Enrollment.create }  
    
    it 'Publishes events for SIS' do
        expect(PipelineService::Events::HTTPClient).to receive(:post)
        PipelineService.publish(enrollment)
    end
end