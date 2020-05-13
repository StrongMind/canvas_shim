describe PipelineService::V2::Nouns::Score do
  include_context "stubbed_network"

  subject { described_class.new(object: noun) }

  let(:active_record_object) { :: Score.create() }

  let(:noun) { PipelineService::V2::Noun.new(active_record_object)}

  describe '#call' do
    it 'is in oneroster format' do
      expect(subject.call).to eq(
        "{
          \"oneroster_result\": {
              \"sourcedId\": \"<sourcedid of this grade>\",
              \"status\": \"active | inactive | tobedeleted\",
              \"dateLastModified\": \"<date this result was last modified>\",
              \"lineitem\": {
                  \"href\": \"<href to this lineitem>\",
                  \"sourcedId\": \"<sourcedId of this lineitem>\",
                  \"type\": \"lineitem\"
              },

              \"student\": {
                  \"href\": \"<href to this student>\",
                  \"sourcedId\": \"<sourcedId of this student>\",
                  \"type\": \"user\"

              },

              \"score\": \"<score of this grade>\",
              \"resultstatus\": \"not submitted | submitted | partially graded | fully graded | exempt\",
              \"date\": \"<date that this grade was assigned>\",
              \"comment\": \"<a comment to accompany the score>\"
          }
        }"
      )
    end
  end
end
