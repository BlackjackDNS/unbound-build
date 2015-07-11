#
# Cookbook Name:: unbound-build
# Recipe:: default
#
# Copyright (C) 2015 John Manero
#
# TODO: MIT License
#
include_recipe 'apt::default'
include_recipe 'build-essential::default'

package 'libtool'
package 'pkg-config'

package 'libevent-dev'
package 'libexpat1-dev'
package 'libssl-dev'
package 'protobuf-c-compiler'

package 'nodejs'

user node['unbound-build']['user'] do
  shell '/bin/bash'
end

## Unbound operator, for testing
user 'unbound' do
  system true
  shell '/usr/sbin/nologin'
end

directory node['unbound-build']['root'] do
  owner node['unbound-build']['user']
  group node['unbound-build']['user']
end

## Fetch the sources to build
remote_file 'unbound-1.5.3' do
  source node['unbound-build']['source']['unbound']
  path ::File.join(node['unbound-build']['root'], 'unbound-1.5.3.tar.gz')
  owner node['unbound-build']['user']
  group node['unbound-build']['user']
end

remote_file 'fstrm-0.2.0' do
  source node['unbound-build']['source']['fstrm']
  path ::File.join(node['unbound-build']['root'], 'fstrm-0.2.0.tar.gz')
  owner node['unbound-build']['user']
  group node['unbound-build']['user']
end

## Unpack and build 'em
unarchive 'unbound-1.5.3' do
  source ::File.join(node['unbound-build']['root'], 'unbound-1.5.3.tar.gz')
  destination ::File.join(node['unbound-build']['root'], 'unbound')
  owner node['unbound-build']['user']
  group node['unbound-build']['user']
end

# unarchive 'fstrm-0.2.0' do
#   source ::File.join(node['unbound-build']['root'], 'fstrm-0.2.0.tar.gz')
#   destination ::File.join(node['unbound-build']['root'], 'fstrm')
#   owner node['unbound-build']['user']
#   group node['unbound-build']['user']
# end
