module PipelineService
    module Nouns
        class Conversation
            class Builder < ActiveRecord::Base
                self.table_name = "conversations"

                def initialize object:
                    @conversation = object
                end
        
                def call
                    Queries::FindByID.query(self, conversation)
                end
        
                private
        
                attr_reader :conversation
            end
        end
    end
end