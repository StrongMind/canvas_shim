module PipelineService
    module Nouns
        class Conversation
            class Builder < ActiveRecord::Base
                self.table_name = "conversations"

                attr_accessor :object
        
                def call
                    Queries::FindByID.query(self.class, object)
                end
            end
        end
    end
end