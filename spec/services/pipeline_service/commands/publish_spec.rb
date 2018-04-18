class Enrollment
  MOCK='yes'
  def id;1;end
end


class DesignerEnrollment < Enrollment;end
class ObserverEnrollment < Enrollment;end
class StudentEnrollment < Enrollment;end
class TeacherEnrollment < Enrollment;end
class Submission;end
class User;end
describe PipelineService::Commands::Publish do
  let(:object)                { Enrollment.new }
  let(:user)                  { double('user') }
  let(:api)                   { double('api', messages_post: nil) }
  let(:test_message)          { double('message') }
  let(:message_builder)       { double('message_builder', build: test_message ) }
  let(:message_builder_class) { double('message_builder_class', new: message_builder) }
  let(:client_instance)       { double('pipeline_client', call: double('call_result', message: test_message)) }
  let(:client_class)          { double('pipeline_client_class', new: client_instance) }
  let(:logger)                { double('logger', log: nil) }
  let(:serializer_class)      { double('serializer_class', new: serializer_instance) }
  let(:serializer_instance)   { double('serializer_instance', call: nil) }

  subject do
    described_class.new(
      object:       object,
      user:         user,
      message_api:  api,
      queue:        false,
      message_builder_class: message_builder_class,
      client:       client_class,
      logger:       logger,
      serializer:   serializer_class
    )
  end

  describe '#call' do
    context 'upsert' do
      it 'sends a message to the pipeline' do
        expect(client_instance).to receive(:call)
        subject.call
      end

      context do
        subject do
          described_class.new(
            object:       object,
            user:         user,
            message_api:  api,
            queue:        false,
            message_builder_class: message_builder_class,
            client:       client_class,
            logger:       logger
          )
        end

        it 'looks up the serializer' do
          expect(subject.call.serializer).to eq PipelineService::Serializers::Enrollment
        end

        context do
          let(:object) { double('unknown object') }
          it 'blows up' do
            expect { subject.call }.to raise_error NameError, 'Could not find the serializer for #[Double "unknown object"]'
          end
        end
      end
    end
  end
end
