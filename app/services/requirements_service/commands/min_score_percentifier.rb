module RequirementsService
  module Commands
    class MinScorePercentifier
      def initialize(content_tag:, passing_threshold:)
        @content_tag = content_tag
        @passing_threshold = passing_threshold
      end

      def call
        self.denominator = points_possible
        percentify_threshold
      end

      private
      attr_reader :content_tag, :passing_threshold
      attr_accessor :denominator

      def points_possible
        content = content_tag.try(:content)
        return 100.0 unless content
        try_points_possible(content) || try_points_possible(content.try(:assignment)) || 100.0
      end

      def try_points_possible(content)
        content.try(:points_possible)
      end

      def percentify_threshold
        (passing_threshold.to_f / denominator.to_f).round(2) * 100
      end
    end
  end
end