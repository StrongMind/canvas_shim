module PipelineService
    module Queries
        module FindByID
            def self.query(active_record_object)
                active_record_object.class
                    .find_by_id(active_record_object.id)
                    .as_json(include_root: false) || {}
            end
        end
    end
end
