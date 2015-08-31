1#!/usr/bin/ruby


require 'net/http'
require 'json/ext'
require 'uri'
require 'date'
require 'time'

ENV['event_id'] = ENV['event_id'] || "-1"
ENV['promo_id'] = ENV['promo_id'] || "-1"
hasdata = false

while true
        eventsuri = URI.parse("http://private-fd322-oddball.apiary-mock.com/events")
        eventshttp = Net::HTTP.new(eventsuri.host)
        eventsrequest = Net::HTTP::Get.new(eventsuri.request_uri)
    begin
        eventsresponse = JSON.parse(eventshttp.request(eventsrequest).body)
        #index = eventsresponse.index{|data| data['event_id'] == ENV['event_id']} 
        #index = index || 0
        eventsresponse = eventsresponse.sort! { |a,b| DateTime.parse(a['start_time']) <=> DateTime.parse(b['start_time'])}
        nextevent = eventsresponse.map {|data| data if DateTime.parse(data['start_time']) >= DateTime.now}.compact.first
        #puts index
        #puts ENV['event_id']
#       eventsresponse = eventsresponse.slice!(0..index)
        #puts eventsresponse
        #eventsresponse = eventsresponse.sort! { |a,b| DateTime.parse(a['start_time']) <=> DateTime.parse(b['start_time'])}
        #nextevent = eventsresponse.map {|data| data if DateTime.parse(data['start_time']) >= DateTime.now }.compact.first      
        #puts nextevent
    rescue JSON::ParserError => e
        puts "parse error"
    end

        promosuri = URI.parse("http://private-fd322-oddball.apiary-mock.com/promotions")
        promoshttp = Net::HTTP.new(promosuri.host)
        promosrequest = Net::HTTP::Get.new(promosuri.request_uri)
    begin
        promosresponse = JSON.parse(promoshttp.request(promosrequest).body)
        promosresponse = promosresponse.sort! { |a,b| DateTime.parse(a['start_time']) <=> DateTime.parse(b['start_time'])}
        nextpromo = promosresponse.map {|data| data if DateTime.parse(data['start_time']) >= DateTime.now}.compact.first
    rescue JSON::ParserError => e
        puts "parse error"
    end
puts nextpromo == nil
puts DateTime.now
puts Time.now
puts nextevent
    if  nextevent != nil or nextpromo != nil
        eventdiff = if nextevent == nil then 9999999999999999 else (Time.parse(nextevent['start_time'].to_s) - Time.parse(DateTime.now.to_s))*1000 end
        promodiff = if nextpromo == nil then 9999999999999999 else (Time.parse(nextpromo['start_time'].to_s) - Time.parse(DateTime.now.to_s))*1000 end
puts eventdiff
puts promodiff
        if eventdiff < promodiff and eventdiff < 300000 and ENV['event_id'].to_i != nextevent['event_id'].to_i
          params = {"app_id" => "ed8429be-4bb9-11e5-9a5a-03d69b25a4bf",
                   "contents" => {"en" => nextevent['artist_id'] + " in 5 minutes"},
                   "included_segments" => ["All"],
		   "small_icon" => "",
                   "large_icon" => "http://res.cloudinary.com/dava4ku0e/image/upload/host-small/" + nextevent['artist_id'] + ".png",
                   "big_picture" => "http://res.cloudinary.com/dava4ku0e/image/upload/w_200,h_200,c_thumb,g_face/host-large/" + nextevent['artist_id'] + ".png",
                   "isAndroid" => "true",
                   "isIos" => "true"}
          ENV['event_id'] = nextevent['event_id']
          hasdata = true
        elsif eventdiff > promodiff and promodiff < 300000 and ENV['promo_id'].to_i != nextpromo['promo_id'].to_i
puts 'inside'
          params = {"app_id" => "ed8429be-4bb9-11e5-9a5a-03d69b25a4bf",
                   "contents" => {"en" => "Flash sale begins in 5 minutes"},
                   "included_segments" => ["All"],
                   "small_icon" => "",
                   "large_icon" => "Icon-29@2x.png",
                   "big_picture" => "oddball_splash.png",
                   "isAndroid" => "true",
                   "isIos" => "true"}
          ENV['promo_id'] = nextpromo['promo_id']
          hasdata = true
        else
          hasdata = false
        end
    end


    if hasdata
          uri = URI.parse('https://onesignal.com/api/v1/notifications')
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          request = Net::HTTP::Post.new(uri.path,
                                      'Content-Type'  => 'application/json',
                                      'Authorization' => "Basic ZWQ4NDJhNWUtNGJiOS0xMWU1LTlhNWItZTcwNzAxZjVhNWIx")
          request.body = params.to_json
          response = http.request(request)
        puts 'notification sent'
    end
  sleep 4
end



#params = {"app_id" => "ed8429be-4bb9-11e5-9a5a-03d69b25a4bf", 
#          "contents" => {"en" => "Rachel Feinstein in a day.."},
#          "included_segments" => ["All"],
#         "small_icon" => "",
#         "large_icon" => "http://res.cloudinary.com/dava4ku0e/image/upload/host-small/RachelFeinstein.png",
#         "big_picture" => "http://res.cloudinary.com/dava4ku0e/image/upload/w_200,h_200,c_thumb,g_face/host-large/RachelFeinstein.png",
#          "isAndroid" => "true"}
#uri = URI.parse('https://onesignal.com/api/v1/notifications')
#http = Net::HTTP.new(uri.host, uri.port)
#http.use_ssl = true
#
#request = Net::HTTP::Post.new(uri.path,
#                              'Content-Type'  => 'application/json',
#                              'Authorization' => "Basic ZWQ4NDJhNWUtNGJiOS0xMWU1LTlhNWItZTcwNzAxZjVhNWIx")
#request.body = params.to_json
#response = http.request(request) 
#puts response.body

