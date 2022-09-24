describe "ContextModuleProgression" do

  context "#uncollapse!" do
    it 'does not raise an exception' do
      context_module_progression = FactoryBot.build(:context_module_progression)
      expect(context_module_progression).to_not raise_exception
    end
  end
end
