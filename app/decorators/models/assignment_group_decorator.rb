AssignmentGroup.class_eval do
  after_commit -> { PipelineService.publish(self) }

  GROUP_NAMES = [ 'Assignment', 'Checkpoint', 'Close Reading Project', 'Discussion', 'Exam', 'Final Exam', 'Pretest', 'Project', 'Workbook' ].freeze
end
