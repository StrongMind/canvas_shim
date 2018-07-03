module GradesService
  def self.zero_out_grades!
    ::Assignment.find_each do |assignment|
      Commands::ZeroOutAssignmentGrades.new(assignment).call!
    end
  end
end
