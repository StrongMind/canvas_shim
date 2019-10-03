module UnitsService
  module Queries
    class GetSubmissions
      def initialize(course:, student:)
        @student = student
        @course = course
      end

      def query
        result = {}
        units.each do |unit, items|
          items.each do |item|
            subs = item.content.try(:submissions) || item.content.try(:assignment).try(:submissions) || quiz_submissions(item)
            if subs.is_a?(Array)
              subs = subs.select {|sub| sub.user_id == @student.id && !sub.excused? }
            elsif subs
              subs = subs.where(user_id: @student.id).where("excused is not true")
            end
            (subs || []).each do |submission|
              result[unit] ||= [] 
              result[unit] << submission 
            end
          end
        end

        result
      end

      def units
        GetItems.new(course: @course).query
      end

      def quiz_submissions(item)
        if item.content_type == "Quizzes::Quiz"
          item.content.quiz_submissions.map {|qs| qs.submission}
        end
      end

    end
  end
end
