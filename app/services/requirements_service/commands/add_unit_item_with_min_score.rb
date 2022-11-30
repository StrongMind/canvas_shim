module RequirementsService
  module Commands
    class AddUnitItemWithMinScore
      def initialize(context_module:, content_tag:, threshold_type:)
        @context_module = context_module
        @content_tag = content_tag
        @course = context_module.course

        if threshold_type.present?
          @setting = threshold_type
        else
          @setting = "#{setting_name}_threshold"
        end

        if
          @score_threshold = RequirementsService.get_passing_threshold(type: 'school', threshold_type: @setting)
        else
          @score_threshold = RequirementsService.get_passing_threshold(type: :course, id: course.try(:id))
        end
      end

      def call
        add_threshold_to_module if gradeable_tag_type? && RequirementsService.get_course_assignment_passing_threshold?(course)
      end

      private

      attr_reader :context_module, :content_tag, :course, :score_threshold

      def gradeable_tag_type?
        %w{Assignment DiscussionTopic Quizzes::Quiz}.include?(content_tag.content_type)
      end

      def add_threshold_to_module
        context_module.completion_requirements << { :id => content_tag.id, :type => "min_score", :min_score => score_threshold }
        context_module.update_column(:completion_requirements, context_module.completion_requirements)
      end
    end
  end
end
