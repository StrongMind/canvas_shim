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
      get 'teacher_alerts'
    end
  end

  resources :observers do
    get 'observers', to: 'observers#index', as: :observed_enrollments
  end

  resources :accounts do
    get 'assign_observers', to: 'accounts#assign_observers'
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
    get '/api/v1/courses/:course_id/enrollments/:id/course_info', action: :observer_popout, as: :popout
  end

  scope(controller: :announcements_api) do
    post '/api/v1/courses/:course_id/announcements/bulk_pin', action: :bulk_pin, as: 'bulk_pin'
    post '/api/v1/courses/:course_id/announcements/reorder_pinned', action: :reorder_pinned, as: 'reorder_pinned'
  end

  ApiRouteSet::V1.draw(self) do
    scope(controller: :users) do
      get 'users/:id/observer_enrollments', action: :observer_enrollments
      post 'users/:id/toggle_progress_grade', action: :toggle_progress_grade
    end

    scope(controller: :user_observees) do
      post 'users/:user_id/bulk_create_observees', action: :bulk_create
      post 'users/:user_id/bulk_destroy_observees', action: :bulk_destroy
    end
  end
end

