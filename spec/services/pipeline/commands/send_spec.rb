module PipelineService
  class PipelineUserAPI
    def enrollment_json(enrollment, user, session)
      {user: {first_name: 'Test', last_name: 'User'}}
    end
  end
end

describe PipelineService::Commands::Send do
  let(:enrollment)   { double('enrollment', id: 1) }
  let(:user)         { double('user') }
  let(:api)          { double('api', messages_post: nil) }
  let(:test_message) { double('message') }

  before do
    ENV['CANVAS_DOMAIN'] = 'someschool.com'
  end

  subject do
    described_class.new(
      enrollment: enrollment,
      user: user,
      message_api: api
    )
  end

  describe '#call' do
    before do
      allow(subject).to receive(:build_pipeline_message) { test_message }
    end

    it 'sends a message to the pipeline' do
      expect(api).to receive(:messages_post).with(test_message)
      subject.call
    end
  end

  describe "#message" do
    it 'shows the message that was sent' do
      expect(subject.call.message.data).to eq(
        {
          :user => { :first_name => "Test", :last_name => "User" }
        })
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
