#
# Cookbook Name:: unbound-build
# Recipe:: default
#
# The MIT License (MIT)
#
# Copyright (c) 2015 John Manero <john.manero@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
include_recipe 'apt::default'
include_recipe 'build-essential::default'

package 'gdb'
package 'libtool'
package 'pkg-config'

package 'libevent-dev'
package 'libexpat1-dev'
package 'libssl-dev'
package 'protobuf-c-compiler'

package 'git'
package 'nodejs'

user node['unbound-build']['user'] do
  shell '/bin/bash'
end

## Unbound operator, for testing
user 'unbound' do
  system true
  shell '/usr/sbin/nologin'
end

directory '/usr/local/etc/unbound' do
  recursive true
  owner 'unbound'
  group 'unbound'
end

template '/usr/local/etc/unbound/unbound.conf' do
  source 'unbound.conf.erb'
end

directory node['unbound-build']['dir'] do
  owner node['unbound-build']['user']
  group node['unbound-build']['user']
end

git node['unbound-build']['dir'] do
  repository node['unbound-build']['repository']
  reference node['unbound-build']['reference']
  user node['unbound-build']['user']
  group node['unbound-build']['user']

  ## Get the Unbound source some other way
  not_if { node['unbound-build']['local'] }
end

[
  'autoreconf -ivf',
  './configure --enable-dnstap',
  "make -j#{ node['cpu']['total'] }",
].each do |command|
  execute command do
    cwd node['unbound-build']['dir']
    user node['unbound-build']['user']
    group node['unbound-build']['user']
  end
end

execute 'make install' do
  cwd node['unbound-build']['dir']
end
