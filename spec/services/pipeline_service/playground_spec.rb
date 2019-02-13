describe "Playground" do
    it 'Publishes events for SIS' do
        User.create
        expect(PipelineService::Events::HTTPClient).to receive(:post).with( {} )
        enrollment = Enrollment.create

        
        allow(enrollment).to receive(:changes).and_return({'workflow_state' => ['active', 'completed']})
        PipelineService.publish(enrollment)
    end
end