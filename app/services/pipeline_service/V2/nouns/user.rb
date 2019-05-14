module PipelineService
  module V2
    module Nouns
      class User
        def initialize object:
          @user = object.ar_model
        end

        def call
          # Return the default, non-overrriden from #as_json
          @user
            .class
            .superclass
            .instance_method(:as_json)
            .bind(@user)
            .call(include_root: false)
        end
      end
    end
  end
end
