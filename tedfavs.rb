require 'rubygems'
require 'sinatra'
require 'haml'

require 'curb'
require 'nokogiri'

get "/" do
  haml :home
end

get "/tedfavs/:id.rss" do
  @favs_uri = "http://www.ted.com/profiles/favorites/id/#{params[:id]}"
  doc = Nokogiri::HTML(Curl::Easy.perform(@favs_uri).body_str)
  @profile_name = doc.at_css('h1 span').text

  m = Curl::Multi.new
  @talks = {}
  doc.css('dl[entitytype=talks]').map do |dl|
    id = dl['entityid']
    uri = "http://www.ted.com/talks/podtv/id/#{id}"
    @talks[id] = ""
    curl = Curl::Easy.new(uri) do |c|
      c.follow_location = true
      c.on_body {|d| @talks[id] << d; d.size}
    end
    m.add(curl)
  end
  m.perform

  @talks = @talks.each    { |k,v| @talks[k] = Nokogiri::XML(v) } \
                 .reject  { |k,v| v.at('//rss').nil? } \
                 .sort_by { |k,v| -k.to_i } \
                 .map     { |k,v| v.at_css('item') }
  @latest_pubdate = Date.parse(@talks.first.at('pubDate').text)

  haml :tedfavs, :layout => false
end
