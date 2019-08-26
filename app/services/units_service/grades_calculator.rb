module UnitsService
  class GradesCalculator
    def initialize unit_submissions, course
      @unit_submissions = unit_submissions
      @course = course
    end

    def call
      result = {}

      @unit_submissions.each do |unit, submissions|
        next if submissions.count == 0
        result[unit] = weighted_average(submissions)
      end

      result
    end

    private

    def weighted_average(submissions)
      category_weights = submissions.map do |submission|
        submission.assignment.assignment_group
      end.map { |ag| [ag.name, ag.group_weight] }.to_h

      result = {}
      submissions.group_by do |submission|
        submission.assignment.assignment_group
      end.each do |group, submissions|
        non_excused = submissions.select do |sub|
          !sub.excused?
        end
        result[group.name] = [] unless result[group]
        average = non_excused.map(&:score).compact.sum.to_f / non_excused.count
        weight  = category_weights[group.name] / category_weights.values.sum
        result[group.name] << average * weight
      end

      result.sum { |r, weighted| weighted.sum }
    end
  end
end
