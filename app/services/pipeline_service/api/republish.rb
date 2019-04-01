module PipelineService
  module API

    # Republish all models given a class and a time range
    #
    # Usage:
    # # republish a specific class within a time range
    # > Republish.call(model: User, range: 3.days.ago...DateTime.now)
    #
    # # republish all classes
    # > Republish.call(range: 3.days.ago...DateTime.now)
    #
    # Notes: 
    # Range is required
    # A submission will also cause a "UnitGrades" to be published
    class Republish
      def initialize(options)
        @range = options[:range]
        raise "Missing required date range" unless @range
        @model = options[:model]
      end
      
      def call
        if model
          publish_model
        else
          publish_all
        end
        self
      end

      private

      attr_accessor :range, :query

      def publish_all
        self.class.models.each do |model|
          @model = model
          publish_model
        end
      end

      def build_query
        @query = {}.tap {|query| query[date_field] = range}
      end

      def publish_model
        build_query
        return unless query
        model.where(query).find_each do |record|
          PipelineService.publish(Nouns::UnitGrades.new(record)) if model == Nouns::UnitGrades || model == Submission
          PipelineService.publish(record)
        end 
      end

      def date_field
        if model.column_names.include?('updated_at')
          :updated_at
        elsif model.column_names.include?('created_at')
          :created_at
        end
      end

      def model
        return Submission if @model == Nouns::UnitGrades
        @model
      end

      def self.models
        [Assignment, ConversationMessage, ConversationParticipant, Conversation, Enrollment, Submission, User]
      end
    end
  end
end