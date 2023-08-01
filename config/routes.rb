# frozen_string_literal: true

Rails.application.routes.draw do
  root 'dashboards#index'
  resources :connections
  resources :courses
  resources :batches do
    member do
      match :add_student, via: %i[get post]
    end
    collection do
      get :add_batch_request
    end
  end
  resources :schools
  devise_for :users
  resources :dashboards do
    collection do
      get :request_review
      get :list_batch
      get :list_school
      get :list_school_admin
      get :list_student
      get :list_course
      get :approve_request
      post :add_batch_request
      get :new_student
      post :create_student
      get :edit_student
      match '/dashboards/:id/update_student', to: 'dashboards#update_student', via: %i[patch put], as: 'update_student'
    end
  end

  namespace :api do
    namespace :v1 do
      root 'dashboards#index'
      resources :connections
      resources :courses
      resources :batches do
        member do
          match :add_student, via: %i[get post]
        end
        collection do
          get :add_batch_request
        end
      end
      resources :schools
      devise_for :users
      resources :dashboards do
        collection do
          get :request_review
          get :list_batch
          get :list_school
          get :list_school_admin
          get :list_student
          get :list_course
          get :approve_request
          post :add_batch_request
          get :new_student
          post :create_student
          get :edit_student
          match '/dashboards/:id/student_update', to: 'dashboards#student_update', via: %i[patch put],
                                                  as: 'student_update'
        end
      end
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "coures#index"
end
