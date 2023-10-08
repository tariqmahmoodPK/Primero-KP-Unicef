# frozen_string_literal: true

# TODO Update the referencing comments after properly updating the files
# TODO Add Explanatory Comments

Rails.application.routes.draw do
  root to: 'home#v2'

  scope :v2 do
    get '/', to: 'home#v2'
    get '*all', to: 'home#v2'
  end

  devise_for(
    :users,
    class_name: 'User',
    path: '/api/v2/tokens',
    controllers: { sessions: 'api/v2/tokens' }, only: :sessions,
    path_names: { sign_in: '', sign_out: '' },
    sign_out_via: :delete,
    defaults: { format: :json }, constraints: { format: :json }
  )

  devise_scope :user do
    get '/v2/password_reset', to: 'home#v2', as: :password_reset
    get '/v2/password_reset_request', to: 'home#v2', as: :password_reset_request
  end

  resources :health, only: %i[index show]
  resources :login, only: [:show]

  namespace :api do
    namespace :v2, defaults: { format: :json },
                   constraints: { format: :json },
                   only: %i[index create show update destroy] do
      resources :primero, only: %i[index]

      resources :children, as: :cases, path: :cases do
        resources :children_incidents, as: :incidents, path: :incidents, only: %i[index new]
        resources :flags, only: %i[index create update]
        resources :alerts, only: [:index]
        resources :assigns, only: %i[index create]
        resources :referrals, only: %i[index create destroy update]
        resources :transfers, only: %i[index create update]
        resources :transfer_requests, only: %i[index create update]
        resources :transitions, only: [:index]
        resources :attachments, only: %i[create destroy]
        resources :approvals, only: [:update]
        resources :potential_matches, only: [:index]
        resources :webhook_syncs, as: :sync, path: :sync, only: [:create]
        get :traces, to: 'children#traces'
        get :record_history, to: 'record_histories#index'
        collection do
          post :flags, to: 'flags#create_bulk'
          post :assigns, to: 'assigns#create_bulk'
          post :referrals, to: 'referrals#create_bulk'
          post :transfers, to: 'transfers#create_bulk'
        end
      end

      resources :incidents do
        resources :flags, only: %i[index create update]
        resources :alerts, only: [:index]
        resources :approvals, only: [:update]
        resources :attachments, only: %i[create destroy]
        post :flags, to: 'flags#create_bulk', on: :collection
        get :record_history, to: 'record_histories#index'
      end

      resources :tracing_requests do
        resources :flags, only: %i[index create update]
        resources :alerts, only: [:index]
        resources :approvals, only: [:update]
        resources :attachments, only: %i[create destroy]
        get :traces, to: 'tracing_requests#traces'
        post :flags, to: 'flags#create_bulk', on: :collection
        get :record_history, to: 'record_histories#index'
      end

      resources :traces, only: %i[show update] do
        resources :potential_matches, only: %i[index]
      end

      resources :form_sections, as: :forms, path: :forms do
        collection do
          get :export, to: 'form_sections#export'
        end
      end

      resources :users do
        post :'password-reset-request', to: 'password_reset#user_password_reset_request'
        collection do
          get :'assign-to', to: 'users_transitions#assign_to'
          get :'transfer-to', to: 'users_transitions#transfer_to'
          get :'refer-to', to: 'users_transitions#refer_to'
          post :'password-reset-request', to: 'password_reset#password_reset_request'
          post :'password-reset', to: 'password_reset#password_reset'
        end
      end

      resources :identity_providers, only: [:index]

      resources :dashboards, only: [:index] do
        collection do
          # 'Percentage of Children who received Child Protection Services'
          get :percentage_children_received_child_protection_services
          # 'Closed Cases by Sex and Reason'
          get :resolved_cases_by_gender_and_reason
          # Cases Referral (To Agency )
          get :cases_referral_to_agency_stats
          # 'Cases requiring Alternative Care Placement Services'
          get :alternative_care_placement_by_gender
          #  Registered and Closed Cases by Month
          get :month_wise_registered_and_resolved_cases_stats
          # Significant Harm Cases by Protection Concern
          get :significant_harm_cases_registered_by_age_and_gender_stats
          # Registered Cases by Protection Concern
          get :registered_cases_by_protection_concern
        end
      end

      resource :contact_information, only: %i[show update], controller: 'contact_information'
      resources :system_settings, only: [:index]
      resources :tasks, only: [:index]
      resources :saved_searches, only: %i[index create destroy]
      resources :reports, only: %i[index show create update destroy]
      resources :lookups
      resources :locations do
        collection do
          post :import, to: 'locations#import'
          post :update_bulk, to: 'locations#update_bulk'
        end
      end
      resources :bulk_exports, as: :exports, path: :exports, only: %i[index show create destroy]
      get 'alerts', to: 'alerts#bulk_index'
      resources :agencies
      resources :webhooks
      resources :roles
      resources :permissions, only: [:index]
      resources :user_groups
      resources :primero_modules, only: %i[index show update]
      resources :audit_logs, only: [:index]
      resources :primero_configurations, as: :configurations, path: :configurations
      resources :flags_owners, as: :flags, path: :flags, only: %i[index]
      resources :key_performance_indicators, path: :kpis, only: [:show]
      resources :codes_of_conduct, only: %i[index create], controller: 'codes_of_conduct'
      resources :activity_log, only: [:index]
      resources :managed_reports, only: %i[index show] do
        collection do
          get :export, to: 'managed_reports#export'
        end
      end
      resources :registry_records do
        resources :flags, only: %i[index create update]
        resources :alerts, only: [:index]
        get :record_history, to: 'record_histories#index'
      end
    end
  end
end
