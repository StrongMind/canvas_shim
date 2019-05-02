class TodoController < ApplicationController

    def index
        enable_fp_todo = SettingsService.get_settings(object: 'school', id: 1)['enable_full_page_todo']
        raise ActionController::RoutingError.new('Not Found') unless enable_fp_todo
        render 'todo_list'
    end
end
  