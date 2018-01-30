# Ruboty::Chatwork

Chatwork adapter for [Ruboty](https://github.com/r7kamura/ruboty).

## Usage
Get your ChatWork API Token

``` ruby
# Gemfile
gem 'ruboty-chatwork'
```

## ENV

```
CHATWORK_API_TOKEN             - ChatWork API Token
CHATWORK_ROOM                  - ChatWork Room ID
CHATWORK_API_RATE              - ChatWork API Rate(Requests per Hour)
CHATWORK_ROOM_FOR_SAYING       - ChatWork Room ID for Saying(Optional)
```

## HOW TO SET THE ROOM TO SAY MESSAGE
- Priority is high in numerical order (lower is ignored)
    1. `room_id:12345678` statement at last in message by saying 
        - ex. `ruboty Good Morning! room_id:12345678` 
    2. `room_id` key in `reply` method
        - ex. `message.reply("Hello!", room_id:12345678)`
    3. ENV["CHATWORK_ROOM_FOR_SAYING"]
    4. ENV["CHATWORK_ROOM"]
- Note
    - regexp of extracting `room_id` is poor ;)

## Contributing

1. Fork it ( http://github.com/mhag/ruboty-chatwork/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
