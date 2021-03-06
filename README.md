[![Gem Version](https://badge.fury.io/rb/actionpack-direct_routes.svg)](https://badge.fury.io/rb/actionpack-direct_routes)
[![Build Status](https://travis-ci.com/hamuyuuki/actionpack-direct_routes.svg?branch=master)](https://travis-ci.com/hamuyuuki/actionpack-direct_routes)
[![Maintainability](https://api.codeclimate.com/v1/badges/37a26fb3d2dbec167997/maintainability)](https://codeclimate.com/github/hamuyuuki/actionpack-direct_routes/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/37a26fb3d2dbec167997/test_coverage)](https://codeclimate.com/github/hamuyuuki/actionpack-direct_routes/test_coverage)

# actionpack-direct_routes
`actionpack-direct_routes` backports Direct routes into Rails 4 and Rails 5.0.

Rails 5.1 adds Direct routes that you can create custom URL helpers directly.
[Ruby on Rails 5.1 Release Notes — Ruby on Rails Guides](https://guides.rubyonrails.org/5_1_release_notes.html#direct-resolved-routes)

## Getting Started
Install `actionpack-direct_routes` at the command prompt:
```sh
gem install actionpack-direct_routes
```

Or add `actionpack-direct_routes` to your Gemfile:
```ruby
gem "actionpack-direct_routes"
```

## How to use
You can create custom URL helpers directly. For example:
```ruby
direct :homepage do
  "http://www.rubyonrails.org"
end

# >> homepage_url
# => "http://www.rubyonrails.org"
```

For details to [Rails Routing from the Outside In — Ruby on Rails Guides](https://guides.rubyonrails.org/routing.html#direct-routes)

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/hamuyuuki/actionpack-direct_routes. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License
`actionpack-direct_routes` is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
