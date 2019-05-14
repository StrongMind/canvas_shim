module PipelineService
    describe Serializers::User do
        let(:user) { double('user', id: 35, name: 'test', short_name: 'test', sortable_name: 'test', lti_context_id: 'bob') }
        subject { described_class.new(object: user) }

        before do
            allow(::User).to receive(:find).and_return(user)
        end

        it '#has lti context id' do
          expect(subject.call).to eq ({"id"=>35, "lti_context_id"=>"bob", "name"=>"test", "short_name"=>"test", "sortable_name"=>"test"})
        end
    end
end
