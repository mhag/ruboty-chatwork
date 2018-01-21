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

        url_for_saying = chatwork_messages_url_for_saying(message)

        req = Net::HTTP::Post.new(url_for_saying.path, headers)
        req.form_data = { 'body' => message[:body] }

        https = Net::HTTP.new(url_for_saying.host, url_for_saying.port)
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

      def chatwork_room_for_saying(message)
        message[:original][:room_id] || message[:room_id] || ENV["CHATWORK_ROOM_FOR_SAYING"] || ENV["CHATWORK_ROOM"]
      end

      def chatwork_messages_url_for_saying(message)
        URI.join(chatwork_url, "/v2/rooms/#{chatwork_room_for_saying(message)}/messages")
      end

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
            message       = JSON.parse(res.body)
            original_body = message[0]['body']

            body          = remove_room_id_statement(original_body)
            from_name     = message[0]['account']['name']
            room_id       = extract_room_id_statement(original_body)

            robot.receive(
              body: body,
              from_name: from_name,
              room_id: room_id,
            )
          end

          sleep (60 * 60) / chatwork_api_rate
        end
      end

      def extract_room_id_statement(original_body)
        original_body[/(.*)( room_id:([0-9]+))\z/, 3]
      end

      def remove_room_id_statement(original_body)
        if !(original_body[/(.*)( room_id:([0-9]+)\z)/, 1].nil?)
          return original_body[/(.*)( room_id:([0-9]+)\z)/, 1].rstrip
        else
          original_body
        end
      end
    end
  end
end
