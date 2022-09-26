describe "ContextModuleProgression" do

  context "#uncollapse!" do
    it 'does not raise an exception when one record is being updated by one variable' do
      # arrange
      cmp = FactoryBot.build(:context_module_progression)
      allow(cmp).to receive(:publish_course_progress).and_return(nil)
      cmp.save
      # act / #assert
      expect { cmp.uncollapse! }.to_not raise_error(ActiveRecord::StaleObjectError)
    end

    it 'does not raise an exception when one record is being updated by two different variables' do
      cmp0 = FactoryBot.build(:context_module_progression)
      allow(cmp0).to receive(:publish_course_progress).and_return(nil)
      cmp0.collapsed = false
      cmp0.save!

      cmp1 = ContextModuleProgression.find(cmp0.id)
      allow(cmp1).to receive(:publish_course_progress).and_return(nil)
      cmp1.collapse = false
      cmp1.save!

      cmp2 = ContextModuleProgression.find(cmp0.id)
      allow(cmp2).to receive(:publish_course_progress).and_return(nil)

      expect{ cmp2.save}.to_not raise_exception(ActiveRecord::StaleObjectError)
    end
  end
end
