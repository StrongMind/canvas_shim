module GradesService
  def self.zero_out_grades!
    ::Assignment.all.each do |assignment|
      Commands::ZeroOutAssignmentGrades.new(assignment).call!
    end
  end
end
