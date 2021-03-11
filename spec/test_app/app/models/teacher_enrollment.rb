class TeacherEnrollment < Enrollment
    scope :active, -> { where("workflow_state IS NULL OR workflow_state<>'deleted'") }
end