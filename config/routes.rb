CanvasShim::Engine.routes.draw do
  namespace "settings_api" do
    namespace 'v1' do
      resources :users, only: ['update']
    end
  end
end

Rails.application.routes.draw do
  resources :cs_alerts do
    collection do
      post 'bulk_delete'
    end
  end
  resources :courses do
    post 'conclude_users', to: 'courses#conclude_users', as: :conclude_user_enrollments
    get  'conclude_users', to: 'courses#show_course_enrollments', as: :show_course_enrollments
    get 'snapshot', to: 'courses#snapshot', as: :snapshot
    post 'distribute_due_dates', to: 'courses#distribute_due_dates', as: :distribute_due_dates
    post 'clear_due_dates', to: 'courses#clear_due_dates', as: :clear_due_dates
  end

  get 'todos', to: 'todos#index', as: :user_todo

  scope(controller: :enrollments_api) do
    post '/api/v1/courses/:course_id/enrollments/:id/custom_placement', action: :custom_placement, as: :custom_placement
    get '/api/v1/courses/:course_id/enrollments/:id/snapshot', action: :snapshot, as: :snapshot
  end

  scope(controller: :announcements_api) do
    post '/api/v1/courses/:course_id/announcements/bulk_pin', action: :bulk_pin, as: 'bulk_pin'
  end
end

