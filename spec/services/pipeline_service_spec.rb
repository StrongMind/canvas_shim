describe PipelineService do
  before do
    ENV['PIPELINE_ENDPOINT'] = 'https://example.com'
    ENV['PIPELINE_USER_NAME'] = 'example_user'
    ENV['PIPELINE_PASSWORD'] = 'example_password'
    ENV['CANVAS_DOMAIN'] = 'someschool.com'
    allow(SettingsService).to receive(:get_settings).and_return({})
    allow(PipelineService::Account).to receive(:account_admin).and_return(account_admin)
  end

  subject { described_class }
  let(:account_admin) { double('account', id: 1)}
  let(:serializer_instance) { double('Serializer Instance', call: nil) }
  let(:serializer) { double('Serializer', new: serializer_instance) }
  let(:enrollment) { double('Enrollment', pipeline_serializer: serializer, id: 1) }
  let(:api_instance) { double('api_instance', call: nil) }
  let(:api) { double('api', new: api_instance) }
  let(:submission) { double('submission', grader_id: 1) }

  describe '#publish' do
    it 'Calls the API instance' do
      expect(api_instance).to receive(:call)
      subject.publish(enrollment, api: api)
    end

    it "Can be turned off" do
      allow(SettingsService).to receive(:get_settings).and_return({'disable_pipeline' => true})
      expect(api_instance).to_not receive(:call)
      subject.publish(enrollment, api: api)
    end

    it "Does not send zero grader events" do
      expect(api_instance).to_not receive(:call)
      subject.publish(submission, api: api)
    end

    context 'when the object is a hash' do
      it 'works' do
        expect do
          subject.publish(
            { id: 1, last_activity_at: Time.now },
            api: api,
            noun: 'enrollment'
          )
        end.to_not raise_error
      end
    end
  end
end

module PipelineService
  module Delayed
    module Job
      def self.enqueue(job)
      end
    end
  end
end
