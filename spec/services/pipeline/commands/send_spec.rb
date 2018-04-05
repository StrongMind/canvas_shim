class HTTParty
  def self.post(url, options={})
  end
end

class MockEnrollment
  def id;1;end
end

describe PipelineService::Commands::Send do
  let(:object)       { MockEnrollment.new }
  let(:user)         { double('user') }
  let(:api)          { double('api', messages_post: nil) }
  let(:serializer)   { double('serializer', call: {
    :id => 1, :first_name=>"Test", :last_name=>"User"
  })}
  let(:test_message) { double('message') }

  before do
    ENV['PIPELINE_ENDPOINT'] = 'https://example.com'
    ENV['PIPELINE_USER_NAME'] = 'example_user'
    ENV['PIPELINE_PASSWORD'] = 'example_password'
    ENV['CANVAS_DOMAIN'] = 'someschool.com'
  end

  subject do
    build_send_command
  end

  def build_send_command(message_type: :upserted)
    described_class.new(
      object: object,
      user: user,
      message_api: api,
      serializer: serializer,
      queue: false,
      message_type: message_type
    )
  end

  describe '#call' do
    context 'upsert' do
      before do
        allow(subject).to receive(:build_pipeline_message) { test_message }
      end

      it 'sends a message to the pipeline' do
        expect(api).to receive(:messages_post).with(test_message)
        subject.call
      end
    end
  end

  describe "#message" do
    let(:message) { subject.call.message }

    it 'has a noun' do
      expect(message.noun).to eq('mock_enrollment')
    end

    it 'has metadata' do
      expect(message.meta).to eq({:source=>"canvas", :domain_name=>"someschool.com"})
    end

    it 'has data' do
      expect(message.data).to be_present
    end

    it 'has identifiers' do
      expect(message.identifiers).to eq :id => 1
    end
  end

  describe '#meta' do
    let!(:meta) do
      command = subject.call
      command.message.meta
    end

    it 'has the domain name of the school' do
      expect(meta[:domain_name]).to eq 'someschool.com'
    end

    it 'has the source of the app' do
      expect(meta[:source]).to eq 'canvas'
    end
  end
end
