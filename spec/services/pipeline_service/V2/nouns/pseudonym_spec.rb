describe PipelineService::V2::Nouns::Pseudonym do
  include_context "stubbed_network"

  subject { described_class.new(object: noun) }

  let(:active_record_object) { ::Pseudonym.create(user_id: user.id, sis_user_id: '1234', created_at: Time.now, last_login_at: Time.now) }
  let!(:user) { ::User.create }

  let(:noun) { PipelineService::V2::Noun.new(active_record_object)}

  describe '#call' do
    it 'does not return sensitive data' do
      expect(subject.call).to eq({
        "created_at" => active_record_object.created_at,
        "id" => active_record_object.id,
        "last_login_at" => active_record_object.last_login_at,
        "sis_user_id" => "1234",
        "user_id" => user.id,
        "unique_id" => nil
      })
    end
  end
end
