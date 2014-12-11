# Docker Ruby

This repo auto-generates Dockerfiles for a bunch of different flavors of
MRI Ruby and JRuby using what's currently available to
[`ruby-install`][ruby-install].

Look in the `rubies/` directory to see available
[Docker Hub tags][docker-hub-tags], e.g. `abevoelker/ruby:ruby-2.1.5`.

The `abevoelker/ruby:latest` tag should reflect the latest stable MRI
interpreter.

A real app's Dockerfile should inherit from this image, add an application
user, add git, do a source checkout and `bundle install`, etc.

## Generating `rubies/`

To update all the Ruby version Dockerfiles available under `rubies/`,
do `make build`.

## Old version

This image used to also provide:

* Postgres 9.3 client and development headers
* latest git binaries
* latest nginx
* latest Node.js binaries (for best execjs performance)
* Supervisor with an nginx config included
* ImageMagick
* locale set to en_US.UTF-8

But I decided that was getting outside the scope of the idea of a "Ruby" image.
If you want the old version with these extras, it's still available using the
tag `abevoelker/ruby:old`.

## License

MIT license.

[docker-hub-tags]: https://registry.hub.docker.com/u/abevoelker/ruby/tags/manage/
[ruby-install]:    https://github.com/postmodern/ruby-install
