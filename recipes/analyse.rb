#
# Cookbook Name:: history-analysis
# Recipe:: analyse
#
# Copyright 2015, Mapzen
#
# Available under the GNU GPLv3, see LICENSE for more details.
#

srcdir = node[:history_splitter][:srcdir]
dstdir = node[:history_splitter][:dstdir]
bucket = node[:history_splitter][:planet_bucket]
path = node[:history_splitter][:planet_file_name]
osm2pgsql_srcdir = "#{srcdir}/osm2pgsql"

%w(
  postgresql-9.3-postgis-2.1
  python-psycopg2
  python-yaml
  autoconf
  automake
  libtool
  make
  g++
  pkg-config
  libboost-dev
  libboost-system-dev
  libboost-filesystem-dev
  libboost-thread-dev
  libexpat1-dev
  libgeos-dev
  libgeos++-dev
  libpq-dev
  libbz2-dev
  libproj-dev
  zlib1g-dev
  lua5.2
  liblua5.2-dev
).each do |p|
  package p
end

directory dstdir do
  action :create
  user "analysis"
  group "users"
  mode "0755"
end

git osm2pgsql_srcdir do
  repository "https://github.com/openstreetmap/osm2pgsql.git"
  revision "master"
  notifies :run, "execute[osm2pgsql-make-install]", :immediate
end

execute "osm2pgsql-make-install" do
  command "./autogen.sh && ./configure && make install"
  cwd osm2pgsql_srcdir
  action :nothing
end

execute "make-pg-superuser" do
  command "createuser -s analysis"
  user "postgres"
  cwd dstdir
  not_if { File.exist? "#{dstdir}/.created_pg_user" }
end

file "#{dstdir}/.created_pg_user" do
  action :touch
  user "analysis"
  mode "0644"
end

cookbook_file "#{node[:history_splitter][:dstdir]}/default.style" do
  source "default.style"
  user "analysis"
  group "users"
  mode "0644"
end

cookbook_file "#{node[:history_splitter][:dstdir]}/queries.yaml" do
  source "queries.yaml"
  user "analysis"
  group "users"
  mode "0644"
end

template "#{node[:history_splitter][:dstdir]}/process_files.py" do
  source "process_files.py.erb"
  user "analysis"
  group "users"
  mode "0644"
end

template "#{node[:history_splitter][:dstdir]}/process_all_files.sh" do
  source "process_all_files.sh.erb"
  user "analysis"
  group "users"
  mode "0755"
end
