describe PipelineService::Helpers::AdditionalIdentifiers do
    subject { described_class }

    let(:payload) { { 'conversation_id' => 1 } }
    let(:additional_identifiers) {
        subject.from_payload(
            payload: payload, 
            fields: [:conversation_id]
        )
    }

    it 'returns the payload ' do
        expect(additional_identifiers).to eq(payload)
    end

    context 'empty payload' do
        let(:additional_identifiers) {
            subject.from_payload(
                payload: {}, 
                fields: [:foo]
            )
        }

        it 'returns an empty payload' do
            expect(additional_identifiers).to eq({})
        end
    end
end