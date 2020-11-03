describe PipelineService::V2::Client do
  include_context 'stubbed_network'

  before { Timecop.freeze }

  describe '#publish' do
    let(:sqs_instance) { double('sqs_instance') }

    before do
      allow(SettingsService).to receive(:get_settings).and_return(
        'pipeline_sqs_url' => 'sqs_url'
      )
      allow(Aws::SQS::Client).to receive(:new).and_return(sqs_instance)
    end

    let(:payload) do
      {
        :noun => "page_view",
        :meta => { :source=>"canvas", :domain_name=>"localhost", :api_version=>1, :status=>nil },
        :identifiers => { :id=>"f52127ea-261a-407c-8f2c-e97ce8fc6ebb" },
        :data => {},
        :published_at => Time.now.to_f
      }
    end

    it 'calls sqs' do
      expect(sqs_instance).to receive(:send_message)
        .with(
          queue_url: 'sqs_url',
          message_body: payload.to_json
        )
      PipelineService::V2::Client.publish(payload)
    end
  end
end
