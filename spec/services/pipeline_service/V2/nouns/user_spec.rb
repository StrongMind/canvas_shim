describe PipelineService::V2::Nouns::User do
  include_context "stubbed_network"

  subject { described_class.new(object: noun) }

  let(:active_record_object) { ::User.create }
  let!(:pseudonym) { ::Pseudonym.create(user_id: active_record_object.id, sis_user_id: '1234') }


  let(:noun) { PipelineService::V2::Noun.new(active_record_object)}

  describe '#call'do
    it 'returns with sis_user_id' do
      expect(subject.call).to include({'sis_user_id' => '1234'})
    end

    context "with partner name" do
      allow(SettingsService).to receive(:get_settings).and_return('partner_name' => 'testschool')
      it 'returns with a partner name' do
        expect(subject.call).to include({'partner_name' => 'testschool'})
      end
    end
    
    context "without partner name" do
      allow(SettingsService).to receive(:get_settings).and_return({})
      it 'returns with a partner name' do
        expect(subject.call).to include({'partner_name' => nil})
      end
    end

  end
end
