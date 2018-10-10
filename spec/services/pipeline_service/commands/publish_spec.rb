class Enrollment
  def id;1;end

  def changes
  end

  def root_account
    Struct.new(:id).new(1)
  end
end

describe PipelineService::Commands::Publish do
  let(:object)              { Submission.new }
  let(:user)                { double('user') }
  let(:test_message)        { {} }
  let(:client_instance)     { double('pipeline_client', call: double('call_result', message: test_message)) }
  let(:client_class)        { double('pipeline_client_class', new: client_instance) }
  let(:serializer_class)    { double('serializer_class', new: serializer_instance) }
  let(:serializer_instance) { double('serializer_instance', call: nil) }
  let(:responder_instance)   { double('responder_instance') }
  let(:responder_class)      { double('responder_class', new: responder_instance) }
  let(:account_admin)       { double('account', id: 1)}

  before do
    allow(SettingsService).to receive(:get_settings).and_return({})
    allow(PipelineService::Account).to receive(:account_admin).and_return(account_admin)

  end

  subject do
    described_class.new(
      object:       object,
      user:         user,
      client:       client_class,
      serializer:   serializer_class,
      responder:     responder_class
    )
  end

  describe '#call' do
    it 'sends a message to the pipeline' do
      expect(client_instance).to receive(:call)
      subject.call
    end

    it 'can be turned off' do
      allow(SettingsService).to receive(:get_settings).and_return({'disable_pipeline' => true})
      expect(client_instance).to_not receive(:call)
      subject.call
    end

    it 'does not publish zero grader graded items' do
      allow(object).to receive(:grader_id).and_return(account_admin.id)
      expect(client_instance).to_not receive(:call)
      subject.call
    end

  end
end
