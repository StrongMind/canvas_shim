module PipelineService
  module Builders
    class AssignmentGroupJSONBuilder < ActiveRecord::Base
      self.table_name = "assignment_groups"

      def self.call(noun)
        # Dont include root.  See active record initializer
        Queries::FindByID.query(self, noun)
      end
    end
  end
end
