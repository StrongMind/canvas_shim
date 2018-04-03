class HTTParty
  def self.post(url, options={})
  end
end

describe PipelineService::Commands::Send do
  let(:enrollment)   { double('enrollment', id: 1) }
  let(:user)         { double('user') }
  let(:api)          { double('api', messages_post: nil) }
  let(:serializer)   { double('serializer', enrollment_json: {
    :user => { :first_name=>"Test", :last_name=>"User" }})
  }
  let(:test_message) { double('message') }

  before do
    ENV['PIPELINE_ENDPOINT'] = 'https://example.com'
    ENV['PIPELINE_USER_NAME'] = 'example_user'
    ENV['PIPELINE_PASSWORD'] = 'example_password'
    ENV['CANVAS_DOMAIN'] = 'someschool.com'
  end

  subject do
    build
  end

  def build(message_type: :upserted)
    described_class.new(
      enrollment: enrollment,
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

    context 'delete' do
      it 'sends a blank object if the message type is delete' do
        expect(build(message_type: :removed).call.message.data).to eq(
          { }
        )
      end
    end
  end

  describe "#message" do
    it 'shows the message that was sent' do
      expect(subject.call.message.data).to eq(
        { :user => { :first_name => "Test", :last_name => "User" }})
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
