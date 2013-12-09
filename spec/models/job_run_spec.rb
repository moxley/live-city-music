require 'spec_helper'

describe JobRun do
  it 'saves and queries' do
    artist = Artist.create name: 'foo'
    run = JobRun.new job_type: 'genre_discovery', sub_type: 'reverb', target: artist
    run.save.should be_true
  end
end
