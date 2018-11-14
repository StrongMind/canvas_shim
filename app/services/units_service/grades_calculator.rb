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


        result[unit.id] = weighted_average(filtered) / filtered.count
      end

      result
    end

    private

    def weighted_average(submissions)
      result = {}
      grouped = submissions.group_by {|submission| submission.assignment.assignment_group}

      grouped.each do |group, submissions|
        result[group.name] = [] unless result[group]
        result[group.name] << submissions.sum
      end

      submissions.sum(&:score)
      # 70% average checkpoint grade, weighted at 20% (divided by a sum category weight of 30%)
      # 70 * (20/30)  = 46.667
      # +
      # 50% average discussion grade, weighted at 10% (divided by a sum category weight of 30%)
      # 50 * (10/30) = 16.667
      # Then, you add the categories:
      # 46.667 + 16.667 = 63.33% Unit Grade for the student
    end

    def category_weights
      Queries::GetCategoryWeights.new(@course).query
    end
  end
end
