describe PipelineService::V2::Commands::PublishToPipeline do
  let(:payload) do 
    {
      :noun => "page_view",
      :meta => { :source=>"canvas", :domain_name=>"localhost", :api_version=>1, :status=>nil },
      :identifiers => { :id=>"f52127ea-261a-407c-8f2c-e97ce8fc6ebb" },
      :data => {}
    }
  end

  it 'Sends payload to client' do
    expect(PipelineService::V2::Client).to receive(:publish).with(payload)
    described_class.new(payload).call
  end

  context "stubbed" do
    include_context "stubbed_network"

    it "adds a published_at timestamp with payload" do
      Timecop.freeze
      current_time = Time.now.utc
      published = described_class.new(payload)
      allow(PipelineService::V2::Client).to receive(:publish)
      published.call
      expect(published.instance_variable_get(:@payload)[:published_at]).to be current_time.to_f
    end
  end
end