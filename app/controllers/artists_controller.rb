class ArtistsController < ApplicationController
  def show
    @artist = Artist.find(params[:id])
    @genre_points = @artist.genre_points.includes(:genre)
    peer_ids = ArtistsEvent.
      joins("JOIN artists_events ae ON ae.event_id = artists_events.event_id").
      where("ae.artist_id=?", @artist.id).
      where.not(artists_events: {artist_id: @artist.id}).
      pluck(:artist_id)
    @peers = Artist.where(id: peer_ids)

    event_ids = Event.joins(:artists_events).
      where(artists_events: {artist_id: @artist.id}).
      pluck('distinct artists_events.event_id')
    @events = Event.where(id: event_ids).
      includes(:venue)
  end
end
