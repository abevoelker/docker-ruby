# Ruby Dockerfile

A Dockerfile that builds:
 * MRI Ruby 2.1.2 + `bundler` gem (system-wide install)
 * Postgres 9.3 client and development headers
 * latest `git` binaries
 * latest `nginx`
 * latest Node.js binaries (for best `execjs` performance)
 * `supervisord` with an nginx config included
 * ImageMagick

A real app's Dockerfile should inherit from this image, add an application
user, add a source checkout and `bundle install`, add a supervisord config
for running the application code with puma or unicorn, etc.

## License

MIT license.
