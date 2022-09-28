describe "ContextModuleProgression" do

  context "#uncollapse!" do
    it 'does not raise an exception when one record is being updated by one variable' do
      # arrange
      cmp = FactoryBot.build(:context_module_progression)
      allow(cmp).to receive(:publish_course_progress).and_return(nil)
      cmp.save
      # act / #assert
      expect { cmp.uncollapse! }.not_to raise_error
    end

    it 'does not raise an exception when one record is being updated by two different variables' do
      cmp0 = FactoryBot.build(:context_module_progression)
      allow(cmp0).to receive(:publish_course_progress).and_return(nil)
      cmp0.collapsed = true
      cmp0.save!

      cmp1 = ContextModuleProgression.find(cmp0.id)
      allow(cmp1).to receive(:publish_course_progress).and_return(nil)
      cmp2 = ContextModuleProgression.find(cmp0.id)
      allow(cmp2).to receive(:publish_course_progress).and_return(nil)

      cmp1.collapsed = false
      cmp1.save!

      expect{ cmp2.uncollapse! }.not_to raise_error
    end
  end
end
