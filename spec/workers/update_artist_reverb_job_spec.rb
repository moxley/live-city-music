require 'spec_helper'

describe UpdateArtistReverbJob do
  let(:dependencies) do
    double(:dependencies).tap do |d|
      d.stub get_genres:    genres,
             find_artist:   artist,
             reverb_source: source
    end
  end
  let(:source) { stub_model(DataSource, id: 1) }
  let(:genres) { ['g1', 'g2'] }
  subject(:job) { UpdateArtistReverbJob.new(dependencies: dependencies) }
  let(:artist) do
    double(:artist).tap do |a|
      a.stub(name: 'a1')
    end
  end

  describe '#perform' do
    it 'saves genres to artist' do
      artist.should_receive(:add_genres!).with(source, genres)
      JobRun.should_receive(:create!).with(target: artist, job_type: 'update_artist_from_source', sub_type: 'reverb', status: 'success')
      job.perform(1)
    end
  end

  describe 'integration', integration: true do
    describe '#perform' do
      it 'adds genres' do
        artist = Artist.create! name: 'The Stubborn Lovers'
        job = UpdateArtistReverbJob.new
        reverb = DataSource.create! name: 'reverb', url: 'asdf'

        JobRun.count.should eq 0
        VCR.use_cassette('update_artist_reverb_job/thestubbornlovers') do
          job.perform(artist.id)
        end
        genre_points = GenrePoint.includes(:genre).load
        genre_names = Set.new(genre_points.map { |gp| gp.genre.name })
        genre_names.should eq Set.new(['Americana', 'Alt Country', 'Roots'])
        JobRun.count.should eq 1
      end
    end
  end
end
