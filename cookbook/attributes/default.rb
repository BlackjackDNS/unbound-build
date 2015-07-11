#
# Cookbook Name:: unbound-build
# Attribute:: default
#
# Copyright (C) 2015 John Manero
#
# TODO: MIT License
#
default['unbound-build']['root'] = '/usr/local/src/unbound-build'
default['unbound-build']['user'] = 'vagrant'

default['unbound-build']['source']['fstrm'] = 'https://github.com/farsightsec/fstrm/releases/download/v0.2.0/fstrm-0.2.0.tar.gz'
default['unbound-build']['source']['unbound'] = 'http://unbound.nlnetlabs.nl/downloads/unbound-1.5.3.tar.gz'
