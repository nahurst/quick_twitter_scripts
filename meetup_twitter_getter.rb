# Gets all the twitter handles for a list of meetup groups.
# Fill in meetup_urls, and it's ready to run.

require 'rubygems'
require 'nokogiri'
require 'open-uri'

meetup_urls = [
  "http://www.meetup.com/ruby-75"
]

def process_meetup_urls(meetup_urls)
  meetup_urls.each do |meetup_url|
    @f = File.new(sanitize_filename(meetup_url), "w")
    @f.puts(meetup_url)
    puts meetup_url

    begin
      doc = Nokogiri::HTML(open(members_url(meetup_url)))
      end_offset = find_end_offset(doc)
      offset_change = 20

      0.step(end_offset, offset_change).to_a.
          map { |page| members_url(meetup_url, page) }.each do |url|
        
        process_members_page(url)
      end    
    rescue Exception => e
      @f.puts "Unable to process #{meetup_url} at all."  
      @f.puts $!
      @f.puts e.backtrace
    ensure
      @f.close unless @f.nil?
    end
  end
end

def process_members_page(url)
  begin
    doc = Nokogiri::HTML(open(url))
  
    doc.css("a.memName").each do |profile_anchor|
      profile_link = profile_anchor.attributes['href'].value
      profile = Nokogiri::HTML(open(profile_link))
	
      twitter_node = profile.css("li.twitterLink a")
      if twitter_node && twitter_node.count > 0
        twitter_link = twitter_node.first.attributes['href'].value
        m = /twitter.com\/([^\/]+)/.match(twitter_link)
        @f.puts m[1] if m
      end
    end
  rescue Exception => e
    @f.puts "Unable to process members page #{url}"
    @f.puts $!
    @f.puts e.backtrace
  end
end

def find_end_offset(doc)
  last_result_set_link = doc.css("li.relative_page a").last.attributes['href'].value
  m = /offset=(\d+)/.match(last_result_set_link)
  if m
    m[1].to_i
  else
    300
  end
end

def members_url(meetup_url, offset=0)
  "#{meetup_url}/members/?offset=#{offset}&desc=1&sort=chapter_member.atime"
end

def sanitize_filename(meetup_url)
  meetup_url.gsub(/[\/\.:]/, '_') + ".txt"
end

process_meetup_urls(meetup_urls)
