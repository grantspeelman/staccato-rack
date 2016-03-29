# Staccato::Rack

[![Gem Version](https://badge.fury.io/rb/staccato-rack.svg)](https://badge.fury.io/rb/staccato-rack)
[![Build Status](https://travis-ci.org/grantspeelman/staccato-rack.png?branch=master)](https://travis-ci.org/grantspeelman/staccato-rack)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'staccato-rack'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install staccato-rack

## Usage

using in middleware:

```ruby
  require 'staccato/rack'
  use Staccato::Rack::Middleware, 'UA-TRACKING-KEY-HERE'
```

using in your Rails application, add the following line to your application config file (`config/application.rb` for Rails 3 and above, `config/environment.rb` for Rails 2):

```ruby
  require 'staccato/rack'
  config.middleware.use Staccato::Rack::Middleware, 'UA-TRACKING-KEY-HERE'
```

if you want logging in rails add a initializers file with the following

```ruby
  require 'staccato/rack'
  MyApi::Application.configure do
    config.middleware.use Staccato::Rack::Middleware, Rails.application.secrets.ga_tracking_id, logger: Rails.logger
  end
```

Note that all post to Google analytics are does in a separate thread to prevent holding up the rack request

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/staccato-rack/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
