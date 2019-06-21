module Api
  module V1
    module User
      def enrollment_json(object, user, options={})
        {
            "grades" => {
                "html_url" => "",
                "current_score" => 0,
                "current_grade" => nil,
                "final_score" => 0,
                "final_grade" => nil
            }  
        }
      end 
    end
  end
end
