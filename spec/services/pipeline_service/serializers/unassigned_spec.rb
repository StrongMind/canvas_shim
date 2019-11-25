module PipelineService
    describe Serializers::Unassigned do
        let(:assignment) { Assignment.new(course: Course.new) }
        subject { described_class.new(object: Models::Noun.new(assignment)) }

        before do
            allow(::Assignment).to receive(:find).and_return(assignment)
            allow(SettingsService).to receive(:get_settings).and_return({"unassigned_students"=>"1093,574,574,574"})
        end

        it 'returns an unassigned object with things' do
            Timecop.travel(Time.zone.local(2019, 11, 1, 13, 0, 0)) do
                result = subject.call
                expect(result).to eq("{\"assignment_id\":null,\"unassigned_at\":\"2019-11-01T13:00:00Z\",\"unassigned_students\":[1093,574,574,574]}")
            end
          end

    end
end