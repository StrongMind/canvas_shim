describe PipelineService do
  before do
    ENV['PIPELINE_ENDPOINT'] = 'https://example.com'
    ENV['PIPELINE_USER_NAME'] = 'example_user'
    ENV['PIPELINE_PASSWORD'] = 'example_password'
    ENV['CANVAS_DOMAIN'] = 'someschool.com'
  end

  subject { described_class }
  let(:serializer_instance) { double('Serializer Instance', call: nil) }
  let(:serializer) { double('Serializer', new: serializer_instance) }
  let(:enrollment) { double('Enrollment', pipeline_serializer: serializer, id: 1) }
  let(:api_instance) { double('api_instance', call: nil) }
  let(:api) { double('api', new: api_instance) }

  describe '#publish' do
    it 'Runs the api command' do
      expect(api_instance).to receive(:call)
      subject.publish(enrollment, api: api)
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
