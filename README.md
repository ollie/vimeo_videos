# VimeoVideos

Simple library for uploading videos through Vimeo V2 API, uses OAuth 1.

## Internals

There are two classes: `VimeoVideos::Client` and `VimeoVideos::Upload`.
The purpose of the `Client` class is:

1. Provide a proxy interface (`upload` method),
2. Do the network talking.

Whereas the `Upload` class is supposed to:

1. Use the client to get user/video info to decide what to do,
2. Do everything related to files.

The interface is built in such a way that the `Upload` instance gets the
`Client` instance through a constructor argument (not calling
it statically).

## Installation

Add this line to your application's Gemfile:

    gem 'vimeo_videos'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vimeo_videos

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it (https://github.com/ollie/vimeo_videos/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Development

    $ bundle exec rspec              # Run tests
    $ bundle exec rubocop .          # Check code style
    $ bundle exec yard doc           # Generate and check documentation
    $ gem build vimeo_videos.gemspec # Make sure it builds and doesn't print warning

    $ rake                           # Tests, rubocop and doc
    $ rake combo                     # Ditto
    $ rake mega_combo                # Ditto and gem build

## Resources

* [https://developer.vimeo.com/apis/advanced/upload](https://developer.vimeo.com/apis/advanced/upload)
* [https://github.com/vimeo/vimeo-php-lib/blob/master/vimeo.php](https://github.com/vimeo/vimeo-php-lib/blob/master/vimeo.php)
* [https://github.com/vimeo/vimeo-php-lib/blob/master/upload.php](https://github.com/vimeo/vimeo-php-lib/blob/master/upload.php)
* [https://github.com/vimeo/vimeo.php](https://github.com/vimeo/vimeo.php)
* [https://github.com/matthooks/vimeo](https://github.com/matthooks/vimeo)
* [https://github.com/novelys/easy-vimeo/blob/master/lib/easy-vimeo.rb](https://github.com/novelys/easy-vimeo/blob/master/lib/easy-vimeo.rb)
* [https://github.com/laserlemon/simple_oauth](https://github.com/laserlemon/simple_oauth)
