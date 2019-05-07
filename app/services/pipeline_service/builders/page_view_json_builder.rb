module PipelineService
  module Builders
    class PageViewJSONBuilder < ActiveRecord::Base
      self.table_name = "page_views"

      def self.call(noun)
        # Dont include root.  See active record initializer
        Queries::FindByID.query(self, noun)
      end
    end
  end
end
