class BrowseController < ApplicationController
  def genres
    @genres = Genre.for_today
  end

  def artists_by_genre
    id = params[:genre_id]
    @genre = Genre.find(id)
    @artists = Artist.today_by_genre_id(id)
  end
end
