# Kiip

[![Travis Status](https://travis-ci.org/rweng/kiip.svg)](https://travis-ci.org/rweng/kiip)
[![codecov.io](http://codecov.io/github/rweng/kiip/coverage.svg?branch=master)](http://codecov.io/github/rweng/kiip?branch=master)

Kiip, just another dotfiles tool to move your actual files and folders to a repository (which can be synced by another tool) and replace them with symlinks.

## Terminology

- `Castle`: the place where your packages are stored, e.g. `~/Dropbox/kiip`
- `Task`: How to sync your packages. Right now, only via symlink.

## Installation

    $ gem install kiip

## Usage

    Commands:
      kiip help [COMMAND]   # Describe available commands or one specific command
      kiip list             # lists all tasks
      kiip rm NAME          # removes task with name NAME, see: kiip help rm
      kiip track NAME PATH  # tracks the file or folder under PATH with the name NAME

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rweng/kiip. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

