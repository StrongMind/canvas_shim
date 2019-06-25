describe RequirementsService::Commands::AddThresholdOverrides do
  include_context 'stubbed_network'
  subject { described_class.new(context_module: context_module, requirements: new_requirements) }

  let(:course) { double('course', id: 1) }
  
  let(:context_module) do 
    double(
      'context module', 
      completion_requirements: old_completion_requirements,
      course: course,
      add_min_score_to_requirements: nil,
      update_column: nil,
      touch: nil
    ) 
  end

  let(:old_completion_requirements) do
    [
      {:id=>53, :type=>"must_view"},
      {:id=>56, :type=>"min_score", :min_score=>70.0},
      {:id=>58, :type=>"min_score", :min_score=>70.0}
    ]
  end

  let(:new_requirements) do
    {
      "56" => { "type" => "must_contribute" },
      "58" => { "type" => "min_score", "min_score" => "72.0"}
    }
  end

  describe "#call" do
    #
  end
end