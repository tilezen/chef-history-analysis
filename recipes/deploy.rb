#
# Cookbook Name:: history-analysis
# Recipe:: deploy
#
# Copyright 2015, Mapzen
#
# Available under the GNU GPLv3, see LICENSE for more details.
#

dstdir = node[:history_splitter][:dstdir]
bucket = node[:history_splitter][:planet_bucket]
path = node[:history_splitter][:planet_file_name]

directory dstdir do
  action :create
  owner "root"
  group "root"
  mode "0755"
end

execute "download-planet" do
  command "wget -q -c -O planet.osh.pbf 'http://s3.amazonaws.com/#{bucket}#{path}'"
  cwd dstdir
end

template "#{dstdir}/splitter.config" do
  source "splitter.config.erb"
end

execute "split-planet" do
  action :nothing
  subscribes :run, "template[#{dstdir}/splitter.config]", :delayed
  subscribes :run, "run[download-planet]", :delayed
  command "LD_LIBRARY_PATH=/usr/local/lib /usr/local/bin/osm-history-splitter 'planet.osh.pbf' 'splitter.config'"
  cwd dstdir
end
