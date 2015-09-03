1#!/usr/bin/ruby


require 'net/http'
require 'json/ext'
require 'uri'
require 'date'
require 'time'

ENV['event_id'] = ENV['event_id'] || "-1"
ENV['promo_id'] = ENV['promo_id'] || "-1"
events = []
promos = []
hasdata = false

while true
                nextevent = nil
                nextpromo = nil
    eventfiff = 9999999999999999
    promodiff = 9999999999999999
        eventsuri = URI.parse("http://private-fd322-oddball.apiary-mock.com/events")
        eventshttp = Net::HTTP.new(eventsuri.host)
        eventsrequest = Net::HTTP::Get.new(eventsuri.request_uri)
    begin
        eventsresponse = JSON.parse(eventshttp.request(eventsrequest).body)
        eventsresponse = eventsresponse.sort! { |a,b| DateTime.parse(a['start_time']) <=> DateTime.parse(b['start_time'])}
                nextevents = eventsresponse.map {|data| data if DateTime.parse(data['start_time']) >= DateTime.now}.compact
                for evt in nextevents
                   if events.index(evt['event_id']).nil? or events.index(evt['event_id']) == -1 then
                          nextevent = evt
                          break
                   end
                end
        #nextevent = eventsresponse.map {|data| data if DateTime.parse(data['start_time']) >= DateTime.now}.compact.first               
    rescue JSON::ParserError => e
        puts "parse error"
    end

        promosuri = URI.parse("http://private-fd322-oddball.apiary-mock.com/promotions")
        promoshttp = Net::HTTP.new(promosuri.host)
        promosrequest = Net::HTTP::Get.new(promosuri.request_uri)
    begin
        promosresponse = JSON.parse(promoshttp.request(promosrequest).body)
        promosresponse = promosresponse.sort! { |a,b| DateTime.parse(a['start_time']) <=> DateTime.parse(b['start_time'])}
        nextpromos = promosresponse.map {|data| data if DateTime.parse(data['start_time']) >= DateTime.now}.compact
                for pro in nextpromos
                   if promos.index(pro['promo_id']).nil? or promos.index(pro['promo_id']) == -1 then
                          nextpromo = pro
                          break
                   end
                end
    rescue JSON::ParserError => e
        puts "parse error"
    end
puts DateTime.now
puts nextevent
puts nextpromo
    if  nextevent != nil or nextpromo != nil
        eventdiff = if nextevent == nil then 9999999999999999 else (Time.parse(nextevent['start_time'].to_s) - Time.parse(DateTime.now.to_s))*1000 end
        promodiff = if nextpromo == nil then 9999999999999999 else (Time.parse(nextpromo['start_time'].to_s) - Time.parse(DateTime.now.to_s))*1000 end
puts 'eventdiffhere'
puts eventdiff < promodiff
puts eventdiff
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
                  events.push(nextevent['event_id'])
      puts events
          hasdata = true
        elsif eventdiff > promodiff and promodiff < 300000 and ENV['promo_id'].to_i != nextpromo['promo_id'].to_i
          params = {"app_id" => "ed8429be-4bb9-11e5-9a5a-03d69b25a4bf",
                   "contents" => {"en" => "Flash sale begins in 5 minutes"},
                   "included_segments" => ["All"],
                   "small_icon" => "",
                   "large_icon" => "Icon-29@2x.png",
                   "big_picture" => "oddball_splash.png",
                   "isAndroid" => "true",
                   "isIos" => "true"}
                  ENV['promo_id'] = nextpromo['promo_id']
                  promos.push(['promo_id'])
      puts promos
          hasdata = true
        else
          hasdata = false
        end
    else
      hasdata = false
    end
        puts hasdata
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
    if (!eventdiff.nil? and eventdiff > 300000 and eventdiff < 330000)  or (!promodiff.nil? and promodiff > 300000 and promodiff < 330000)
        sleepfor = eventdiff < promodiff ? eventdiff : promodiff
        sleepingfor = eventdiff < promodiff ? "event" : "promo"
sleepfor = (sleepfor.to_i-300000)/1000

        puts "sleeping for " + sleepingfor.to_s + ", " + sleepfor.to_s
        sleepfor = sleepfor > 0 ? sleepfor : 10;
        sleep sleepfor
        #sleep 3                
    else
        puts "sleeping for 60 secs"
        sleep 60
    end
end
                                                                                                                                                                                           