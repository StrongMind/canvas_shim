module PipelineService
    module Queries
        module FindByID
            def self.query(builder, noun)
                builder
                    .find_by_id(noun.id)
                    .as_json(include_root: false) || {}
            end
        end
    end
end
