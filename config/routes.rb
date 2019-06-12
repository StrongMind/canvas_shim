CanvasShim::Engine.routes.draw do
  
  
  namespace "settings_api" do
    namespace 'v1' do
      resources :users, only: ['update']
    end
  end
end

Rails.application.routes.draw do
  resources :seasuite_alerts
  resources :courses do
    post 'conclude_users', to: 'courses#conclude_users', as: :conclude_user_enrollments
    get  'conclude_users', to: 'courses#show_course_enrollments', as: :show_course_enrollments
  end

  
  
  get 'todos', to: 'todos#index', as: :user_todo
end
