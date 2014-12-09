import jinja2
import requests
from collections import namedtuple
import itertools
import os.path
import os

VERSION_URL = "https://raw.githubusercontent.com/postmodern/ruby-versions/master/{0}/versions.txt"
RUBY_INTERPRETERS = ['ruby', 'jruby', 'rubinius']
RUBIES_DIR = 'rubies'

RubyVersion = namedtuple("RubyVersion", "interpreter version")

def include_file(name):
    return jinja2.Markup(loader.get_source(env, name)[0])

loader = jinja2.PackageLoader(__name__, '.')
env = jinja2.Environment(loader=loader)
env.globals['include_file'] = include_file

def get_ruby_versions(i):
    versions = filter(None, requests.get(VERSION_URL.format(i)).text.split('\n'))
    return [RubyVersion(i, version) for version in versions]

nested_versions = [get_ruby_versions(interp) for interp in RUBY_INTERPRETERS]
versions = list(itertools.chain.from_iterable(nested_versions))

for v in versions:
    ruby_version            = v.interpreter + ' ' + v.version
    ruby_version_hyphenated = v.interpreter + '-' + v.version
    ruby_version_dir        = RUBIES_DIR + '/' + ruby_version_hyphenated

    if not os.path.exists(ruby_version_dir):
        os.makedirs(ruby_version_dir)

    # ruby.sh
    rubysh =  env.get_template('includes/ruby.sh.j2').render(
      ruby_version_hyphenated=ruby_version_hyphenated
    )
    with open(ruby_version_dir + '/ruby.sh', 'w') as f:
        f.write(rubysh)
    os.chmod(ruby_version_dir + '/ruby.sh', 0755)

    # Dockerfile
    dockerfile =  env.get_template('Dockerfile.j2').render(
      ruby_version=ruby_version,
      ruby_version_hyphenated=ruby_version_hyphenated
    )
    with open(ruby_version_dir + '/Dockerfile', 'w') as f:
        f.write(dockerfile)
