module PipelineService
    module Queries
        module FindByID
            def self.query(builder, noun)
                lookup = {}
                lookup[noun.primary_key] = noun.id
                builder
                  .find_by(lookup)
                  .as_json(include_root: false) || {}
            end
        end
    end
end
