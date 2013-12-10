require 'spec_helper'

describe ArtistReverbBatchJob do
  def create_job_run(artist, job_date)
    JobRun.create! job_type:   'artist_source_update',
                   sub_type:   'reverb',
                   target:     artist,
                   status:     'success',
                   created_at: job_date,
                   updated_at: job_date
  end

  let(:recent_artist) do
    Artist.create!(name: 'recent_artist').tap do |a|
      create_job_run(a, 1.day.ago)
    end
  end

  let(:artist_updated_old) do
    Artist.create!(name: 'artist_updated_old').tap do |a|
      create_job_run(a, 1.month.ago)
    end
  end

  let(:artist_never_updated) do
    Artist.create!(name: 'artist_never_updated')
  end

  let(:artists_by_id) { {} }

  def create_artists
    artists_by_id[recent_artist.id ] = recent_artist
    artists_by_id[artist_updated_old.id] = artist_updated_old
    artists_by_id[artist_never_updated.id] = artist_never_updated
  end

  subject(:job) { ArtistReverbBatchJob.new }

  describe '#perform', integration: true do
    it 'performs a UpdateArtistReverbJob on every applicable artist' do
      create_artists

      artists = []
      UpdateArtistReverbJob.stub(:perform_async) do |id|
        artists << artists_by_id[id]
      end

      job.perform

      names = artists.map(&:name)

      # Assert inclusion
      names.should_not include 'recent_artist'
      names.should include 'artist_updated_old'
      names.should include 'artist_never_updated'

      # Assert order
      names[0].should eq 'artist_never_updated'
      names[1].should eq 'artist_updated_old'
    end
  end
end
