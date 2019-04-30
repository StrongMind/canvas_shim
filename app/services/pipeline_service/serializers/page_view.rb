module PipelineService
  module Serializers
    class PageView
      def initialize object:
        @page_view = object
      end

      def call
        @payload = Builders::PageViewJSONBuilder.call(@page_view) || {}
      end

    end
  end
end
