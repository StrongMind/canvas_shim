module PipelineService
  module Delayed
    module Job
      def self.enqueue(job)
      end
    end
  end
end

describe PipelineService do
  subject { described_class }
  let(:serializer_instance) { double('Serializer Instance', call: nil) }
  let(:serializer) { double('Serializer', new: serializer_instance) }
  let(:enrollment) { double('Enrollment', pipeline_serializer: serializer, id: 1) }

  describe '#publish' do
    context "Queued" do
      it 'enqueues the job' do
        expect(PipelineService::Delayed::Job).to receive(:enqueue)
        subject.publish(enrollment)
      end
    end

    context "Without Queue" do
      let(:command) { double('command', call: nil) }

      before do
        allow(PipelineService).to receive(:command) { command }
        @env_value = ENV['PIPELINE_SKIP_QUEUE']
        ENV['PIPELINE_SKIP_QUEUE'] = 'true'
      end

      after do
        ENV['PIPELINE_SKIP_QUEUE'] = @env_value
      end

      it 'wont enqueue' do
        expect(PipelineService::Delayed::Job).to_not receive(:enqueue)
        subject.publish(enrollment)
      end

      it 'will call the command inline' do
        expect(command).to receive(:call)
        subject.publish(enrollment)
      end
    end
  end
end
