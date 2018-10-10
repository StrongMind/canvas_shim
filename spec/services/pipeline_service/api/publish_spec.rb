
describe PipelineService::API::Publish do
  let(:submission)          { double('submission', id: 1, class: 'Submission', grader_id: nil, assignment: double('assignment')) }
  let(:command_instance)    { double('command_instance', call: nil) }
  let(:command_class)       { double('command_class', new: command_instance) }
  let(:queue)               { double('queue') }
  let(:account_admin)       { double('account', id: 1)}



  subject do
    described_class.new(
      submission,
      command_class: command_class,
      queue: queue
    )
  end

  describe '#call' do
    before do
      allow(SettingsService).to receive(:get_settings).and_return({})
      allow(PipelineService::Account).to receive(:account_admin).and_return(account_admin)

    end

    it 'has uses the lowest priority' do
      expect(queue).to receive(:enqueue).with(subject, hash_including(priority: 1000000))
      subject.call
    end


    it 'can be turned off' do
      allow(SettingsService).to receive(:get_settings).and_return({'disable_pipeline' => true})
      allow(queue).to receive(:enqueue)
      expect(queue).to_not receive(:enqueue)
      subject.call
    end

    it 'does not publish zero grader graded items' do
      allow(submission).to receive(:grader_id).and_return(account_admin.id)
      allow(queue).to receive(:enqueue)
      expect(queue).to_not receive(:enqueue)
      subject.call
    end

  end
end
