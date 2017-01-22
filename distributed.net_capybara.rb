# distributed.net search, built on Capybara & PhantomJS

# Docker environment containing Capybara and PhantomJS can be found:
#    https://github.com/rwhitworth/docker-capybara-poltergeist
# This code works as a copy and paste script within the Pry environment

module Dnet
  class << self
    include Capybara::DSL

    def user_stats(user_url, username)
      # accepts user URL as input
      # accepts user name as input
      # returns hash (plus _yesterday_ versions):
      # overall_rank
      # overall_percentile
      # overall_blocks
      # overall_blocks_sec
      # time_working
      
      # example URL: http://stats.distributed.net/participant/psummary.php?project_id=8&id=482116
      
      visit user_url
      
      result = Hash.new
      result[:username] = username
      
      a = page.find_all('tr').collect {|x| x if x.find_all('td', :class => 'phead2') }.collect {|x| x.text }
      res = a.collect {|x| x if x.include?('Rank: ') }.compact.first.match('Rank: (\d{1,10}).* (\d{1,10})')
      result[:overall_rank] = res[1]
      result[:yesterday_rank] = res[2]
      res = a.collect {|x| x if x.include?('Percentile: ') }.compact.first.match('Percentile: (\d{1,10}\.\d{0,2}) (\d{1,10}\.\d{0,2})')
      result[:overall_percentile] = res[1]
      result[:yesterday_percentile] = res[2]
      res = a.collect {|x| x if x.include?('Blocks: ') }.compact.first.match('Blocks: ([0-9,]{1,20}) ([0-9,]{1,20})')
      result[:overall_blocks] = res[1]
      result[:yesterday_blocks] = res[2]
      res = a.collect {|x| x if x.include?('Blocks/sec: ') }.compact.first.match('Blocks/sec: ([0-9,\.]{1,20}) ([0-9,\.]{1,20})')
      result[:overall_blockssec] = res[1]
      result[:yesterday_blockssec] = res[2]
      res = a.collect {|x| x if x.include?('Keys: ') }.compact.first.match('Keys: ([0-9,\.]{1,30}) ([0-9,\.]{1,30})')
      result[:overall_keys] = res[1]
      result[:yesterday_keys] = res[2]
      res = a.collect {|x| x if x.include?('Keys/sec: ') }.compact.first.match('Keys/sec: ([0-9,]{1,30}) ([0-9,]{1,30})')
      result[:overall_keyssec] = res[1]
      result[:yesterday_keyssec] = res[2]
      res = a.collect {|x| x if x.include?('Time Working: ') }.compact.first.match('Time Working: ([0-9,]{1,30}) days')
      result[:time_working] = res[1]
      
      result
    end
  end
end


visit 'http://stats.distributed.net'

a = page.all('a').collect {|x| [x[:href],x.text] if x[:href].include?('project')}.compact

visit a.collect {|x| x[0] if x[1] == 'RC5-72' }.compact.first

b = page.all('form', :id => 'par-search').first

b.fill_in 'st', :with => 'Bob'
b.click_button

#######
_pry_.config.pager = false
#######

# Note: this only gathers the list of users from the first page of results
users = []
users << page.find_all('tr', :class => 'row1').collect {|x| x.all('a').first }
users << page.find_all('tr', :class => 'row1').collect {|x| x.all('a').first }
users.flatten!

users_url = users.collect{|x| [x[:href], x.text] }

stats = users_url.collect {|x| Dnet.user_stats(x[0], x[1]) }

# stats now contains the results of the search
