require 'httpclient'
require 'pp'

class Dnet
  attr_accessor :username
  attr_accessor :project_number
  attr_accessor :body

  def initialize(username, project_number = 28)
    @username = username
    @project_number = project_number
    @clnt = HTTPClient.new(:agent => 'RUBY HTTPlib/1.0 (https://github.com/rwhitworth/distributed.net)', :base_url => 'http://stats.distributed.net/')

    @clnt.redirect_uri_callback = lambda do |uri, res|
      page = res.header['location'].first
      page =~ %r/http/ ? page : uri + page
    end
    query
    true
  end

  def query
    query = { 'project_id' => @project_number, 'st' => @username, 'submit' => 'Search' }
    a = @clnt.get('participant/psearch.php', :query => query, :follow_redirect => true)
    @body = a.body
    return nil if (a.status != 200)
    true
  end

  def overall_ranking
    m = /phead2.*? (\d{1,7}).+?<\/td>/m.match(@body)
    m[1]
  end

  def yesterday_ranking
    m = /Rank:.*?(\d{1,7})<span/m.match(@body)
    m[1]
  end

  def overall_percentile
    m = /Percentile:.+?(\d{1,7}\.\d\d)\ {1,7}<\/td>/m.match(@body)
    m[1]
  end

  def yesterday_percentile
    m = /Percentile:.+?\d.+?(\d{1,7}\.\d\d)\ {1,7}<\/td>/m.match(@body)
    m[1]
  end

  def overall_gnodes
    m = /(Gnodes|Blocks):.+?([\d,]{1,20})<\/td>/m.match(@body)
    m[2]
  end

  def yesterday_gnodes
    m = /(Gnodes|Blocks):.+?\d.*?td.*?([\d,]{1,20})<\/td>/m.match(@body)
    m[2]
  end

  def overall_gnodessec
    m = /(Gnodes|Blocks)\/sec:.+?([\d.]{1,20})/m.match(@body)
    m[2]
  end

  def yesterday_gnodessec
    m = /(Gnodes|Blocks)\/sec:.+?\d.*?td.*?([\d.]{1,20})/m.match(@body)
    m[2]
  end

  def overall_nodes
    m = />(nodes|Keys):.+?([\d,]{1,30})/m.match(@body)
    m[2]
  end

  def yesterday_nodes
    m = />(nodes|Keys):.+?\d.*?td.*?([\d,]{1,20})/m.match(@body)
    m[2]
  end

  def overall_nodessec
    m = />(nodes|Keys)\/sec:.+?([\d,]{1,20})/m.match(@body)
    m[2]
  end

  def yesterday_nodessec
    m = />(nodes|Keys)\/sec:.+?\d.*?td.*?([\d,]{1,20})/m.match(@body)
    m[2]
  end

  def days_working
    m = /Time Working:.+?([\d,]{1,6}) days/m.match(@body)
    m[1]
  end

end


# d = Dnet.new('lithron')
# puts "days=#{d.days_working}"
# puts "overall_ranking=#{d.overall_ranking}"
# puts "yesterday_ranking=#{d.yesterday_ranking}"
# puts "overall_percent=#{d.overall_percentile}"
# puts "yesterday_percent=#{d.yesterday_percentile}"
# puts "overall_gnodes=#{d.overall_gnodes}"
# puts "yesterday_gnodes=#{d.yesterday_gnodes}"
# puts "overall_gnodessec=#{d.overall_gnodessec}"
# puts "yesterday_gnodessec=#{d.yesterday_gnodessec}"
# puts "overall_nodes=#{d.overall_nodes}"
# puts "yesterday_nodes=#{d.yesterday_nodes}"
# puts "overall_nodessec=#{d.overall_nodessec}"
# puts "yesterday_nodessec=#{d.yesterday_nodessec}"
#
# exit 1
