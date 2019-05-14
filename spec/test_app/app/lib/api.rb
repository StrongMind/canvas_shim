module Api
    module V1
        module User
            def enrollment_json(object, user, options={})
            end

            def user_json(object, admin, opts={})
              { "id"=> object.id,
                "name"=> object.name,
                "sortable_name"=> object.sortable_name,
                "short_name"=> object.short_name
              }
            end
        end
    end
end
