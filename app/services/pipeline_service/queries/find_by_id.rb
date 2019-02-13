module PipelineService
    module Queries
        module FindByID
            def self.query(noun)
                record = noun.noun_class.find_by_id(noun.id)
                record.as_json(include_root: false) || {}
            end
        end
    end
end
