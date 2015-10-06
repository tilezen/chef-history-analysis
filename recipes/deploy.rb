#
# Cookbook Name:: history-analysis
# Recipe:: deploy
#
# Copyright 2015, Mapzen
#
# Available under the GNU GPLv3, see LICENSE for more details.
#

dstdir = node[:history_splitter][:dstdir]

directory dstdir do
  action :create
  owner "root"
  group "root"
  mode "0755"
end

s3_file "#{dstdir}/planet.osh.pbf" do
  remote_path node[:history_splitter][:planet_file_name]
  bucket node[:history_splitter][:planet_bucket]
  owner "root"
  group "root"
  mode "0644"
  action :create
end

template "#{dstdir}/splitter.config" do
  source "splitter.config.erb"
end

execute "split-planet" do
  action :nothing
  subscribes :run, "template[#{dstdir}/splitter.config]", :delayed
  subscribes :run, "s3_file[#{dstdir}/planet.osh.pbf]", :delayed
  command "LD_LIBRARY_PATH=/usr/local/lib /usr/local/bin/osm-history-splitter 'planet.osh.pbf' 'splitter.config'"
  cwd dstdir
end
