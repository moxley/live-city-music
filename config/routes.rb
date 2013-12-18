Bands::Application.routes.draw do
  devise_for :users
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  root 'homepage#index'

  require 'sidekiq/web'
  authenticate :user, lambda(&:admin?) do
    mount Sidekiq::Web => '/sidekiq'
  end

  get 'today' => 'browse#genres'
  get 'today/:genre_id/artists' => 'browse#artists_by_genre'
end
