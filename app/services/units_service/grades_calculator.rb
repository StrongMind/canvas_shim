module UnitsService
  # {
  #   course_id: 1,
  #   student_id: 13,
  #   units: {
  #     { id: 1, score: 80 },
  #     { id: 2, grade: 83 },
  #     { id: 3, grade: 74 },
  #     { id: 4, grade: 56 },
  #     { id: 5, grade: 99 },
  #     { id: 6, grade: 12 }
  #   }
  # }

  class GradesCalculator
    def initialize unit_submissions, course
      @unit_submissions = unit_submissions
      @course = course
    end

    def call
      result = {}
      category_weights

      @unit_submissions.each do |unit, submissions|
        next if submissions.count == 0

        filtered = submissions.select do |submission|
          !submission.excused?
        end

        result[unit.id] = weighted_average(filtered)
      end

      result
    end

    private

    def weighted_average(submissions)
      grouped = submissions.group_by do |submission|
        submission.assignment.assignment_group
      end

      result = {}
      grouped.each do |group, submissions|
        result[group.name] = [] unless result[group]
        average = (submissions.sum(&:score)) / submissions.count
        result[group.name] << (
          average * category_weights[group.name] / category_weights.values.sum
        )
      end

      result.sum { |r, weighted| weighted.sum }
    end

    def category_weights
      Queries::GetCategoryWeights.new(@course).query
    end
  end
end
