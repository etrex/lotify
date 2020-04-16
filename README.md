# Lotify

Lotify is a LINE Notify client SDK.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lotify'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lotify

## Usage

### initialize lotify instance

```ruby
lotify = Lotify::Client.new(
  client_id: "your line notify client id",
  client_secret: "your line notify client secret",
  redirect_uri: "your redirect uri"
)
```

### get auth link

```ruby
auth_link = lotify.get_auth_link("state")
```

### get access token

```ruby
code = "you can get code from redirect uri after user click the auth link"
token = lotify.get_token(code)
```

### get status

```
response = lotify.status(token)
```

### send notification

Send a text message.

```
response = lotify.send(token, message: "Hello lotify.")
```

Send a text, image and sticker message at same time.

```
image_url = "https://picsum.photos/240"

response = lotify.send(token,
  message: "Hello lotify.",
  imageThumbnail: image_url,
  imageFullsize: image_url,
  stickerPackageId: 1,
  stickerId: 1
)
```

### revoke access token

```
response = lotify.revoke(token)
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/etrex/lotify.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

