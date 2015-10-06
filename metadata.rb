name             'history-analysis'
maintainer       'mapzen'
maintainer_email 'matt.amos@mapzen.com'
license          'GPL v3'
description      'Installs/Configures history analysis tools'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.1'

recipe 'history-analysis', 'Mapzen History Analysis'

%w(
  apt
  git
  sudo
  ohai
  s3_file
).each do |dep|
  depends dep
end

%w(ubuntu).each do |os|
  supports os
end
