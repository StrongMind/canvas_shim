module PipelineService
  class PipelineUserAPI
    def enrollment_json(enrollment, user, session)
      {user: {first_name: 'Test', last_name: 'User'}}
    end
  end
end
