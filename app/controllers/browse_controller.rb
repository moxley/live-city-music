class BrowseController < ApplicationController
  def genres
    @genres = Genre.for_today(city_slug)
  end

  def artists_by_genre
    id = params[:genre_id]
    @genre = Genre.find(id)
    @artists = Artist.today_by_genre_id(city_slug, id)
  end

  private

  def city_slug
    @city_slug ||= params[:city_slug]
  end
end
