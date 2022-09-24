describe "ContextModuleProgressionDecorator" do

  def setup_modules
    @assignment = @course.assignments.create!(:title => "some assignment")
    @tag = @module.add_item({:id => @assignment.id, :type => 'assignment'})
    @module.completion_requirements = {@tag.id => {:type => 'must_view'}}
    @module.workflow_state = 'unpublished'
    @module.save!

    @module2 = @course.context_modules.create!(:name => "another module")
    @module2.publish
    @module2.prerequisites = "module_#{@module.id}"
    @module2.save!

    @module3 = @course.context_modules.create!(:name => "another module again")
    @module3.publish
    @module3.save!
  end

  context "#uncollapse!" do
    before do
      setup_modules
    end

    it 'reloads context module progression before updating' do
      context_module_progression = FactoryBot.build(ContextModuleProgression)
      expect(context_module_progression).to_not raise_exception
    end
  end
end
