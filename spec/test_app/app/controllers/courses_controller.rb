class CoursesController < ApplicationController
    def update
    end

    def settings
        @context = Course.new(id: 1)
    end
end
