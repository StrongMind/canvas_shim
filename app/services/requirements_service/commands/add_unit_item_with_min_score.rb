module RequirementsService
  module Commands
    class AddUnitItemWithMinScore
      def initialize(context_module:, content_tag:)
        @context_module = context_module
        @content_tag = content_tag
        @content_type = content_tag.content_type
        @course = context_module.course

        @threshold_type = case @content_type
                          when 'Assignment'
                            assignment_group = AssignmentGroup.find(context_module.context_id)
                            assignment_name = assignment_group.name

                            case assignment_name
                            when 'Assignments'
                              'assignment'
                            when 'Projects'
                              'project'
                            when 'Exams'

                            end

                         when 'DiscussionTopic'
                           'discussion'
                         else
                           'assignment'
                         end

        @score_threshold = RequirementsService.get_passing_threshold(type: :course, id: course.try(:id), threshold_type: @threshold_type)
      end

      def call
        has_threshold = case @threshold_type
                        when 'assignment'
                          RequirementsService.get_course_assignment_passing_threshold?(course)
                        when 'discussion'
                          RequirementsService.get_course_discussion_passing_threshold?(course)
                        when 'exam'
                          RequirementsService.get_course_exam_passing_threshold?(course)
                        else
                          RequirementsService.get_course_assignment_passing_threshold?(course)
                          # true
                        end
        add_threshold_to_module if gradeable_tag_type? && has_threshold
      end

      private
      attr_reader :context_module, :content_tag, :course, :score_threshold

      def gradeable_tag_type?
        %w{Assignment DiscussionTopic Quizzes::Quiz}.include?(@content_type)
      end

      def add_threshold_to_module
        context_module.completion_requirements << {:id => content_tag.id, :type => "min_score", :min_score => score_threshold}
        context_module.update_column(:completion_requirements, context_module.completion_requirements)
      end
    end
  end
end
