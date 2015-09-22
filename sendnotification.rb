1#!/usr/bin/ruby

require 'net/http'
require 'json/ext'
require 'uri'
require 'date'
require 'time'
require "http"

ENV['promo_id'] = ENV['promo_id'] || "-1"
promos = []
hasdata = false
notificationsenabled = false
stageurl = "http://ec2-107-21-167-109.compute-1.amazonaws.com:4000"
prourl = "http://ec2-107-21-167-109.compute-1.amazonaws.com:4000"
cloudinaryurl = "http://res.cloudinary.com/dava4ku0e/image/upload/promotions/"

while true  

  baseurl = stageurl
  metadatauri = URI.parse(prourl + "/metadata.json")	
  begin
      metadataresponse = JSON.parse(HTTP.get(metadatauri))
      for data in metadataresponse
         if data["name"] == "enableNotifications" then
            notificationsenabled = data["value"]
         end
         if data["name"] == "promosBaseUrl" then
            cloudinaryurl = data["value"]              
         end
      end    
    rescue JSON::ParserError => e
        puts "parse error"
    end
    nextpromo = nil
    promodiff = 9999999999999999
    promosuri = URI.parse(baseurl + "/promotions.json")       
    begin
        promosresponse = JSON.parse(HTTP.get(promosuri)) #JSON.parse(promoshttp.request(promosrequest).body)        
        promosresponse = promosresponse.sort! { |a,b| DateTime.parse(a['start_time']) <=> DateTime.parse(b['start_time'])}
        nextpromos = promosresponse.map {|data| data if DateTime.parse(data['start_time']) >= DateTime.now}.compact
                for pro in nextpromos
                   if promos.index(pro['id']).nil? or promos.index(pro['id']) == -1 then
                          nextpromo = pro
                          break
                   end
                end
    rescue JSON::ParserError => e
        puts "parse error"
    end
puts DateTime.now
puts nextpromo
    if  nextpromo != nil
      promodiff = if nextpromo == nil then 9999999999999999 else (Time.parse(nextpromo['start_time'].to_s) - Time.parse(DateTime.now.to_s))*1000 end
        if promodiff < 300000 and ENV['promo_id'].to_i != nextpromo['id'].to_i
          params = {"app_id" => "ed8429be-4bb9-11e5-9a5a-03d69b25a4bf",
                   "contents" => {"en" => nextpromo['promotion_name']},
                   "included_segments" => ["All"],
                   "small_icon" => "",
                   "large_icon" => "Icon-29@2x.png",
                   "big_picture" => cloudinaryurl + nextpromo['image'],                   
                   "isAndroid" => "true",
                   "isIos" => "true"}                   
                  ENV['promo_id'] = nextpromo['id'].to_s
                  promos.push(nextpromo['id'])
      puts promos
          hasdata = true
        else
          hasdata = false
        end
    else
      hasdata = false
    end

puts hasdata and notificationsenabled
puts promos
            
    if hasdata and notificationsenabled
          uri = URI.parse('https://onesignal.com/api/v1/notifications')
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          request = Net::HTTP::Post.new(uri.path,
                                      'Content-Type'  => 'application/json',
                                      'Authorization' => "Basic N2U1NzhjMTItNWI5NC0xMWU1LWE0MDEtOWZlMjI2ODdjZmFl")
          request.body = params.to_json
          response = http.request(request)
        puts 'notification sent'        
        if(promos.length >= 10)
          promos = promos.drop(5)
        end
    end
    if (!promodiff.nil? and promodiff > 300000 and promodiff < 330000)
        sleepfor = promodiff
        sleepingfor = "promo"
        sleepfor = (sleepfor.to_i-300000)/1000

        puts "sleeping for " + sleepingfor.to_s + ", " + sleepfor.to_s
        sleepfor = sleepfor > 0 ? sleepfor : 10;
        sleep sleepfor
        #sleep 3                
    else
        puts "sleeping for 300 secs(5 minutes)"
        sleep 60
    end
end
                                                                                                                                                                                           
