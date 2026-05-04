module PipelineService
  module V2
    class Client
      REGION = ENV['AWS_REGION']
      SQS_REGION = 'us-west-2'

      SQS_MAX_BYTES = 262_144
      SIZE_WARNING_RATIO = 0.9
      LOG_TAG = '[pipeline_v2_payload_size]'.freeze
      JOB_TAG = 'PipelineService::V2::API::Publish#call'.freeze

      class PayloadTooLargeError < StandardError; end

      include Singleton

      def initialize

        Aws.config.update(
          region: REGION,
          credentials: Aws::Credentials.new(
            ENV['S3_ACCESS_KEY_ID'],
            ENV['S3_ACCESS_KEY']
          )
        )

        @url = SettingsService.get_settings(object: 'school', id: 1)['pipeline_sqs_url']
        @sqs = Aws::SQS::Client.new(region: SQS_REGION)
      end

      def self.publish(payload)
        instance.publish(payload)
      end

      def publish(payload)
        message_body = payload.to_json
        bytesize = message_body.bytesize

        if bytesize > SQS_MAX_BYTES
          log_payload_size(payload, bytesize, :oversize)
          raise PayloadTooLargeError,
                "PipelineService V2 payload exceeds SQS limit " \
                "(bytesize=#{bytesize} limit_bytes=#{SQS_MAX_BYTES})"
        end

        if bytesize > (SQS_MAX_BYTES * SIZE_WARNING_RATIO)
          log_payload_size(payload, bytesize, :near_limit)
        end

        @sqs.send_message(queue_url: @url, message_body: message_body)
      end

      private

      def log_payload_size(payload, bytesize, threshold_state)
        line = "#{LOG_TAG} " + payload_log_attributes(payload, bytesize, threshold_state).join(' ')

        case threshold_state
        when :oversize
          Rails.logger.error(line)
        when :near_limit
          Rails.logger.warn(line)
        end
      end

      def payload_log_attributes(payload, bytesize, threshold_state)
        attrs = [
          "threshold_state=#{threshold_state}",
          "bytesize=#{bytesize}",
          "limit_bytes=#{SQS_MAX_BYTES}",
          "job_tag=#{JOB_TAG}",
          "noun=#{value_of(payload, :noun).inspect}",
          "canvas_domain=#{value_of(value_of(payload, :meta), :domain_name).inspect}",
          "status=#{value_of(value_of(payload, :meta), :status).inspect}"
        ]

        identifiers = value_of(payload, :identifiers)
        if identifiers.is_a?(Hash)
          identifiers.each do |k, v|
            attrs << "identifier_#{k}=#{v.inspect}"
          end
        end

        data = value_of(payload, :data)
        if data.is_a?(Hash)
          history = value_of(data, :submission_history)
          attrs << "submission_history_count=#{history.size}" if history.is_a?(Array)
          attrs << "data_keys=#{data.keys.map(&:to_s).sort.join(',').inspect}"
        end

        attrs
      end

      def value_of(hash, key)
        return nil unless hash.is_a?(Hash)
        return hash[key] if hash.key?(key)
        return hash[key.to_s] if hash.key?(key.to_s)
        nil
      end
    end
  end
end
