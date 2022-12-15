describe PipelineService::Serializers::Course do
    include_context "stubbed_network"
  
    subject { described_class.new(object: noun) }
  
    let(:active_record_object) { Course.create!() }
    let(:noun) { PipelineService::Models::Noun.new(active_record_object)}

    before do
      allow(SettingsService).to receive(:get_settings).and_return({
        'powerschool_integration' => true,
        'powerschool_course_id' => 254
      })
      allow(RequirementsService).to receive(:get_assignment_group_passing_thresholds).and_return({
        "assignment"=>10.0, 
        "checkpoint"=>20.0, 
        "close_reading_project"=>30.0, 
        "discussion"=>40.0, 
        "exam"=>50.0, 
        "final_exam"=>60.0, 
        "pretest"=>70.0, 
        "project"=>80.0, 
        "workbook"=>90.0
      })

      allow(IdentifierMapperService::Client).to receive(:get_powerschool_school_id).and_return(452)
    end

    it 'Return an attribute hash of the noun' do
      expect(subject.call).to include({
        noun.primary_key => active_record_object.id,
        'passing_thresholds' => {
          "assignment"=>10.0, 
          "checkpoint"=>20.0, 
          "close_reading_project"=>30.0, 
          "discussion"=>40.0, 
          "exam"=>50.0, 
          "final_exam"=>60.0, 
          "pretest"=>70.0, 
          "project"=>80.0, 
          "workbook"=>90.0
        }
      })
    end

    it 'Includes the powerschool_course_id attribute' do
      expect(subject.call).to include({
        :powerschool_course_id => 254
      })
    end

    it 'includes the powerschool_school_id attribute' do
      expect(subject.call).to include({
        :powerschool_school_id => 452
      })
    end

    context "powerschool intergration is unfeatured" do

    before do
      allow(SettingsService).to receive(:get_settings).and_return({
        'powerschool_integration' => false
      })
      allow(RequirementsService).to receive(:get_assignment_group_passing_thresholds).and_return({
        "assignment"=>10.0, 
        "checkpoint"=>20.0, 
        "close_reading_project"=>30.0, 
        "discussion"=>40.0, 
        "exam"=>50.0, 
        "final_exam"=>60.0, 
        "pretest"=>70.0, 
        "project"=>80.0, 
        "workbook"=>90.0
      })
    end

    it 'Return an attribute hash of the noun' do
      expect(subject.call).to include({
        noun.primary_key => active_record_object.id,
        'passing_thresholds' => {
          "assignment"=>10.0, 
          "checkpoint"=>20.0, 
          "close_reading_project"=>30.0, 
          "discussion"=>40.0, 
          "exam"=>50.0, 
          "final_exam"=>60.0, 
          "pretest"=>70.0, 
          "project"=>80.0, 
          "workbook"=>90.0
        }
      })
    end

    it 'Excludes the powerschool_course_id attribute' do
      expect(subject.call).to_not include({
        :powerschool_course_id => 254
      })
    end

    it 'Excludes the powerschool_school_id attribute' do
      expect(subject.call).to_not include({
        :powerschool_school_id => 452
      })
    end
  end
end
