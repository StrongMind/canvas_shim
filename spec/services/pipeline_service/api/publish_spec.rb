describe PipelineService::API::Publish do
  let(:queue)                 { double('queue') }
  let(:publish_command_class)       { double('publish_command_class', new: publish_command_instance) }
  let(:publish_command_instance)    { double('publish_command_instance', call: nil) }
  let(:submission) { 
    double(
      'submission',
      id: 1, 
      class: 'Submission',
      assignment: double('assignment'),
      changes: {},
      assignment_id: 1,
      course_id: 1, 
      user_id: 1
    )
  }  

  context 'When deserializing' do
    it 'the object is a noun' do
      Delayed::Worker.delay_jobs = true
      conversation = Conversation.create
      PipelineService.publish(conversation)
    
      object = YAML.load(Delayed::Job.first.handler).instance_variable_get(:@object)
      expect(object.class).to eq PipelineService::Models::Noun
      Delayed::Worker.delay_jobs = false
    end
  end

  context 'publish non-deletes' do
    
    let(:deleted_wrapper_instance) {}

    subject do
      described_class.new(
        submission,
        publish_command_class: publish_command_class,
        queue: queue
      )
    end

    before do
      allow(SettingsService).to receive(:get_settings).and_return({})
    end

    describe '#call' do
      before do
        allow(queue).to receive(:enqueue)
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
    end
  end

  context 'publishes deleted records' do
    include_context 'pipeline_context'
    let(:conversation) { double('conversation', destroyed?: true) }  
    let(:deleted_noun_class) { PipelineService::Models::Noun }
    let(:deleted_noun_instance) { double('deleted_noun_instance', valid?: true) }

    before do
      allow(PipelineService::Models::Noun)
        .to receive(:new)
        .and_return(deleted_noun_instance)
    end
    
    subject do
      described_class.new(conversation, command_class: publish_command_class)
    end

    it 'builds and sends a deleted wrapper' do
      expect(publish_command_class)
        .to receive(:new)
          .with(hash_including(object: deleted_noun_instance))
          .and_return(publish_command_instance)
        
      subject.call
    end

    context 'the noun is invalid' do
      let(:new_noun) { double('new_noun', valid?: false) }
      let(:deleted_noun_instance) do 
        double('deleted_noun_instance', valid?: false, fetch: new_noun, name: 'assignment', id: 1) 
      end

      it 'Raises an error if it cant get a valid noun ' do
        expect{ subject.call }.to raise_error(RuntimeError, "assignment noun with id=1 is invalid")
      end
      
      context 'valid after fetch' do
        let(:new_noun) { double('new_noun', valid?: true) }

        it 'resets the object if it comes back valid' do
          subject.call
          expect(subject.object).to eq new_noun
        end
      end
    end
  end
end
