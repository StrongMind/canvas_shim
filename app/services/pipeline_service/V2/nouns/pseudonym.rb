module PipelineService
  module V2
    module Nouns
      class Pseudonym < PipelineService::V2::Nouns::Base
        def initialize object:
          @ar_object = object.ar_model
        end
 
        def call
          # Return the default, non-overrriden from #as_json
          res = super
          filtered_keys = ["crypted_password", "password_salt", "persistence_token", "single_access_token", "perishable_token"]
          filtered_keys.map {|key| res.delete(key)}
          res
        end
      end
    end
  end
end
