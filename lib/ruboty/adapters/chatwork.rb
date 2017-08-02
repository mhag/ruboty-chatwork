require 'json'
require 'net/http'
require 'open-uri'
require 'pp'

module Ruboty
  module Adapters
    class Chatwork < Base
      include Mem

      env :CHATWORK_API_TOKEN, "ChatWork API Token"
      env :CHATWORK_ROOM,      "ChatWork Room ID"
      env :CHATWORK_API_RATE,  "ChatWork API Rate(Request per Hour)"

      def run
        listen
      end

      def say(message)
        pp message
        req = Net::HTTP::Post.new(chatwork_messages_url.path, headers)
        req.form_data = { 'body' => message[:body] }
        https = Net::HTTP.new(chatwork_messages_url.host, chatwork_messages_url.port)
        https.use_ssl = true
        https.start {|https| https.request(req) }
      end

      def chatwork_url
        URI.parse(ENV["CHATWORK_URL"] || "https://api.chatwork.com/")
      end
      memoize :chatwork_url

      def chatwork_api_token
        ENV["CHATWORK_API_TOKEN"]
      end
      memoize :chatwork_api_token

      def chatwork_room
        ENV["CHATWORK_ROOM"]
      end
      memoize :chatwork_room

      def chatwork_messages_url
        URI.join(chatwork_url, "/v2/rooms/#{chatwork_room}/messages")
      end
      memoize :chatwork_messages_url

      def chatwork_api_rate
        ENV["CHATWORK_API_RATE"].to_i
      end
      memoize :chatwork_api_rate

      def headers
        {
          'X-ChatWorkToken' => chatwork_api_token,
        }
      end
      memoize :headers

      def listen
        loop do
          req = Net::HTTP::Get.new(chatwork_messages_url.path, headers)
          https = Net::HTTP.new(chatwork_messages_url.host, chatwork_messages_url.port)
          https.use_ssl = true
          res = https.start {|https| https.request(req) }
          pp res.body
          unless res.body.nil?
            message = JSON.parse(res.body)
            robot.receive(
              body: message[0]['body'],
              from_name: message[0]['account']['name']
            )
          end

          sleep (60 * 60) / chatwork_api_rate
        end
      end
    end
  end
end
