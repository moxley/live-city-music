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

  get '/artist/:id', to: 'artists#show', as: 'artist'

  get 'today', to: redirect('/portland-or-us/today')
  get ':city_slug/today' => 'browse#genres'
  get ':city_slug/today/:genre_id/artists' => 'browse#artists_by_genre', as: 'todays_artists_by_genre'
end
