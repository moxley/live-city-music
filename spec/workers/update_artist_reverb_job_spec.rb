require 'spec_helper'

describe UpdateArtistReverbJob do
  let(:dependencies) do
    double(:dependencies).tap do |d|
      d.stub(get_genres: genres)
      d.stub(find_artist: artist)
    end
  end
  let(:genres) { ['g1', 'g2'] }
  subject(:job) { UpdateArtistReverbJob.new(dependencies: dependencies) }
  let(:artist) do
    double(:artist).tap do |a|
      a.stub(name: 'a1')
    end
  end

  describe '#perform' do
    it 'saves genres to artist' do
      artist.should_receive(:add_genres!).with(:reverb, genres)
      JobRun.should_receive(:create!).with(target: artist, job_type: 'update_artist_from_source', sub_type: 'reverb', status: 'success')
      job.perform(1)
    end
  end
end
