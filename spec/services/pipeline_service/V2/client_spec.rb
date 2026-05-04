describe PipelineService::V2::Client do
  include_context 'stubbed_network'

  describe '#publish' do
    let(:sqs_instance) { double('sqs_instance', send_message: nil) }

    let(:payload) do
      {
        :noun => "page_view",
        :meta => { :source => "canvas", :domain_name => "localhost", :api_version => 1, :status => nil },
        :identifiers => { :id => "f52127ea-261a-407c-8f2c-e97ce8fc6ebb" },
        :data => {}
      }
    end

    before do
      Singleton.__init__(PipelineService::V2::Client)
      allow(SettingsService).to receive(:get_settings).and_return(
        'pipeline_sqs_url' => 'sqs_url'
      )
      allow(Aws::SQS::Client).to receive(:new).and_return(sqs_instance)
      allow(Rails.logger).to receive(:warn)
      allow(Rails.logger).to receive(:error)
    end

    context 'when the payload is well under the SQS limit' do
      it 'sends the serialized payload to sqs' do
        expect(sqs_instance).to receive(:send_message)
          .with(queue_url: 'sqs_url', message_body: payload.to_json)
        PipelineService::V2::Client.publish(payload)
      end

      it 'does not emit a payload-size log entry' do
        PipelineService::V2::Client.publish(payload)
        expect(Rails.logger).not_to have_received(:warn)
        expect(Rails.logger).not_to have_received(:error)
      end
    end

    context 'when the payload is near the SQS limit' do
      let(:near_limit_blob) { 'x' * (PipelineService::V2::Client::SQS_MAX_BYTES - 500) }
      let(:near_limit_payload) { payload.merge(data: { blob: near_limit_blob }) }

      it 'still publishes to sqs' do
        expect(sqs_instance).to receive(:send_message)
        PipelineService::V2::Client.publish(near_limit_payload)
      end

      it 'logs a structured warning with identifying metadata' do
        PipelineService::V2::Client.publish(near_limit_payload)
        expect(Rails.logger).to have_received(:warn) do |line|
          expect(line).to include('[pipeline_v2_payload_size]')
          expect(line).to include('threshold_state=near_limit')
          expect(line).to match(/bytesize=\d+/)
          expect(line).to include("limit_bytes=#{PipelineService::V2::Client::SQS_MAX_BYTES}")
          expect(line).to include('noun="page_view"')
          expect(line).to include('canvas_domain="localhost"')
          expect(line).to include('identifier_id="f52127ea-261a-407c-8f2c-e97ce8fc6ebb"')
          expect(line).to include('job_tag=PipelineService::V2::API::Publish#call')
        end
      end

      it 'does not include the raw payload contents in the log line' do
        PipelineService::V2::Client.publish(near_limit_payload)
        expect(Rails.logger).to have_received(:warn) do |line|
          expect(line).not_to include(near_limit_blob)
        end
      end
    end

    context 'when the payload exceeds the SQS limit' do
      let(:oversize_blob) { 'y' * (PipelineService::V2::Client::SQS_MAX_BYTES + 1_000) }
      let(:oversize_payload) do
        payload.merge(
          identifiers: { id: 22970755, assignment_id: 73143, course_id: 502 },
          data: { blob: oversize_blob, submission_history: [{}, {}, {}] }
        )
      end

      it 'does not call sqs' do
        expect(sqs_instance).not_to receive(:send_message)
        expect { PipelineService::V2::Client.publish(oversize_payload) }
          .to raise_error(PipelineService::V2::Client::PayloadTooLargeError)
      end

      it 'raises with bytesize and limit context in the error message' do
        expect { PipelineService::V2::Client.publish(oversize_payload) }
          .to raise_error(
            PipelineService::V2::Client::PayloadTooLargeError,
            /bytesize=\d+ limit_bytes=#{PipelineService::V2::Client::SQS_MAX_BYTES}/
          )
      end

      it 'logs a structured error with identifying metadata before raising' do
        expect { PipelineService::V2::Client.publish(oversize_payload) }
          .to raise_error(PipelineService::V2::Client::PayloadTooLargeError)

        expect(Rails.logger).to have_received(:error) do |line|
          expect(line).to include('[pipeline_v2_payload_size]')
          expect(line).to include('threshold_state=oversize')
          expect(line).to match(/bytesize=\d+/)
          expect(line).to include('noun="page_view"')
          expect(line).to include('canvas_domain="localhost"')
          expect(line).to include('identifier_id=22970755')
          expect(line).to include('identifier_assignment_id=73143')
          expect(line).to include('identifier_course_id=502')
          expect(line).to include('submission_history_count=3')
          expect(line).to include('data_keys="blob,submission_history"')
        end
      end

      it 'does not leak the raw payload contents in the log line' do
        expect { PipelineService::V2::Client.publish(oversize_payload) }
          .to raise_error(PipelineService::V2::Client::PayloadTooLargeError)

        expect(Rails.logger).to have_received(:error) do |line|
          expect(line).not_to include(oversize_blob)
        end
      end
    end
  end
end
