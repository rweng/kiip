# Kiip

[![Travis Status](https://travis-ci.org/rweng/kiip.svg)](https://travis-ci.org/rweng/kiip)
[![codecov.io](http://codecov.io/github/rweng/kiip/coverage.svg?branch=master)](http://codecov.io/github/rweng/kiip?branch=master)

Kiip, just another dotfiles tool to move your actual files and folders to a repository (which can be synced by another tool) and replace them with symlinks.

## Terminology

- `Repository`: the place where your packages are stored, e.g. `~/Dropbox/kiip`
- `Package`: The folder `PATH_TO_REPOSITORY/PACKAGE_NAME`. It can contain multiple entries.
- `Entry`: The file/folder/symlink **in** `PATH_TO_REPOSITORY/PACKAGE_NAME`. It is the real file/folder, with an base64 encoded name of the original path.

## Installation

    $ gem install kiip

## Usage

    Commands:
      kiip help [COMMAND]           # Describe available commands or one specific command
      kiip link PACKAGE_NAME        # ensures links to the package files exist
      kiip list                     # lists all packages with content
      kiip restore PACKAGE_NAME     # restores the content of the package to the original places
      kiip rm NAME                  # removes package with name NAME from the repository
      kiip track PACKAGE_NAME PATH  # tracks the file or folder under PATH with the package name NAM...
      kiip unlink PACKAGE_NAME      # removes the links to the package files
    
    Options:
      -d, [--dry], [--no-dry]
      -v, [--verbose], [--no-verbose]
      
    Examples:
        $ kiip track -v ssh ~/.ssh
        mv /Users/rowe/.ssh /Users/rowe/Sync/home/kiip/ssh/fi8uc3No
        ln -s /Users/rowe/Sync/home/kiip/ssh/fi8uc3No /Users/rowe/.ssh
         
        $ kiip list 
          ssh:
            ~/.ssh | linked
            
        $ kiip unlink -v ssh
        removing ~/.ssh
        
        $ kiip list
            ssh:
              ~/.ssh | not_existent
      
        $ kiip restore -v ssh
        copy /Users/rowe/Sync/home/kiip/ssh/fi8uc3No to ~/.ssh
              
        $ kiip list
            ssh:
              ~/.ssh | directory
              
        $ kiip rm -v ssh
        rm -r /Users/rowe/Sync/home/kiip/ssh
        
        $ kiip list
            
        

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rweng/kiip. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

