module PipelineService
  module Builders
    class CourseJSONBuilder < ActiveRecord::Base
      self.table_name = "courses"

      def self.call(noun)
        # Dont include root.  See active record initializer
        Queries::FindByID.query(self, noun)
      end
    end
  end
end
