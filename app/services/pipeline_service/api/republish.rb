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
      def initialize(model, options)
        @range = options[:range]
        @model = model
      end
      
      def call
        publish
        self
      end

      private

      attr_accessor :range

      def publish      
        model.where(updated_at: range).each do |record|
          PipelineService.publish(Nouns::UnitGrades.new(record)) if @model == Nouns::UnitGrades
          PipelineService.publish(record)
        end
      end

      def model
        return Submission if @model = Nouns::UnitGrades
        @model
      end
    end
  end
end