module PipelineService
  module API

    # Republish all models given a class and a time range
    #
    # Usage: 
    # > Republish.call(User, range: 3.days.ago...DateTime.now)
    #
    # Notes: 
    # A submission will also cause a "UnitGrades" to be published
    class Republish
      def initialize(options)
        @range = options[:range]
        raise "Missing required date range" unless @range
        @model = options[:model]
      end
      
      def call
        publish_model and return self if model
        publish_all
        self
      end

      private

      attr_accessor :range

      def publish_all
        self.class.models.each do |model|
          @model = model
          publish_model
        end
      end

      def publish_model     
        model.where(updated_at: range).each do |record|
          PipelineService.publish(Nouns::UnitGrades.new(record)) if @model == Nouns::UnitGrades
          PipelineService.publish(record)
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