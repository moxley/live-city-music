require 'spec_helper'

describe PageCollector do
  it 'fetches web pages and delivers them via email' do
    response = OpenStruct.new(body: '<html>foo</html>')
    collector = PageCollector.new
    collector.should_receive(:http_fetch).at_least(:once) { response }
    date = Time.now.strftime('%Y%m%d')
    collector.should_receive(:send_mail) do |mail|
      mail.to.should eq ['moxley.stratton@gmail.com']
      mail.attachments.map(&:filename).should include "mercury-#{date}.html"
    end
    collector.collect
  end
end
