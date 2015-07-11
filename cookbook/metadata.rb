name 'unbound-build'
maintainer 'John Manero'
maintainer_email 'john.manero@gmail.com'
license 'MIT'
description 'Installs/Configures a build environment for unbound'
long_description 'Installs/Configures a build environment for unbound'
version IO.read('../VERSION') rescue '0.0.1'

depends 'apt', '~> 2.7'
depends 'build-essential', '~> 2.2'
