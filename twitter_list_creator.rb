# Fills a twitter list with Twitter handles in a file (one handle per line)
# Fill in FILE_PATH and LIST_NAME, and it's ready to run.
#
# Bugs:
# - Lists can only contain 500 users. If there are more than that in the file, they don't get added.

require "rubygems"
require "twitter"

FILE_PATH = ""
LIST_NAME = ""
TWITTER_LIST_MEMBERSHIP_RATE_LIMIT = 100

Twitter.configure do |config|
  config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
  config.oauth_token = ENV['TWITTER_OAUTH_TOKEN']
  config.oauth_token_secret = ENV['TWITTER_OAUTH_TOKEN_SECRET']
end

handles = []
File.open(FILE_PATH).each do |line|
  handles << line.strip
end

Twitter.list_create(LIST_NAME, :mode => 'private')
handles.each_slice(TWITTER_LIST_MEMBERSHIP_RATE_LIMIT) do |handles_up_to_limit|
  begin
    puts "Processing #{handles_up_to_limit.count}"
    Twitter.list_add_members(LIST_NAME, handles_up_to_limit)
    sleep 5
  rescue
    puts $!
  end
end
