name             "ssl-key-vault"
maintainer       "Maciej Pasternacki"
maintainer_email "maciej@3ofcoins.net"
license          'MIT'
description      "SSL key & certificate storage in chef-vault"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.3.0'

chef_version '>= 12.8'
supports 'ubuntu'

gem 'chef-vault'
