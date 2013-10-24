require 'spec_helper'

describe EventParser do
  describe '#artist_names' do
    def artist_names(event_title)
      EventParser.artist_names(event_title)
    end

    it 'returns identity' do
      artist_names('foo').should eq ['foo']
    end

    it 'splits comma-separated names' do
      artist_names('Mike Pardew, Dave Captein').should eq ['Mike Pardew', 'Dave Captein']
    end

    it 'treats "and" as a separator too' do
      artist_names('Mike Pardew, Dave Captein and Randy Rollofson').should eq ['Mike Pardew', 'Dave Captein', 'Randy Rollofson']
    end

    it 'does not tread "and" as a separator if there are other separators after it' do
      artist_names('Edo G., Fifth and Foul, Navia Reigns, Guests').should eq ['Edo G.', 'Fifth and Foul', 'Navia Reigns']
    end

    it 'does not treat "&" as a separator' do
      artist_names('The Babies and Alex Bleeker & The Freaks').should eq ['The Babies', 'Alex Bleeker & The Freaks']
    end

    it 'skips placeholder names like Guests' do
      artist_names('The 32nd Street Singers, Guests').should eq ['The 32nd Street Singers']
    end

    it 'skips placeholder names like Guest' do
      artist_names('The 32nd Street Singers, Guest').should eq ['The 32nd Street Singers']
    end
  end
end
