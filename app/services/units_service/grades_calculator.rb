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
      result = {}
      submissions.group_by do |submission|
        submission.assignment.assignment_group
      end.each do |group, submissions|
        result[group.name] = [] unless result[group]
        average = submissions.sum(&:score).to_f / submissions.count
        weight  = category_weights[group.name] / category_weights.values.sum
        result[group.name] << average * weight
      end

      result.sum { |r, weighted| weighted.sum }
    end

    def category_weights
      Queries::GetCategoryWeights.new(@course).query
    end
  end
end
