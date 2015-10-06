#
# Cookbook Name:: history-analysis
# Recipe:: setup
#
# Copyright 2015, Mapzen
#
# Available under the GNU GPLv3, see LICENSE for more details.
#

%w(
  git
  cmake
  build-essential
  zlib1g-dev
  libexpat1-dev
  libbz2-dev
  libboost-dev
  libboost-program-options-dev
  libgdal-dev
  libproj-dev
  libxml2-dev
  libgeos-dev
  libgeos++-dev
  libsparsehash-dev
  libprotobuf-dev
  protobuf-compiler
  doxygen
  graphviz
).each do |p|
  package p
end

base_srcdir = node[:history_splitter][:srcdir]
osmium_srcdir = "#{base_srcdir}/osmium"
osm_binary_srcdir = "#{base_srcdir}/osm-binary"
osm_history_splitter_srcdir = "#{base_srcdir}/osm-history-splitter"
libosmium_srcdir = "#{base_srcdir}/libosmium"
osmium_tool_srcdir = "#{base_srcdir}/osmium-tool"

# source dir
directory base_srcdir do
  action :create
  owner "root"
  group "root"
  mode "0755"
end

# make osmium (old library)
execute "osmium-make-install" do
  action :nothing
  command "make doc install"
  cwd osmium_srcdir
end

git osmium_srcdir do
  repository "https://github.com/joto/osmium.git"
  revision "7f23002a95b619ac0479ea00347d18f41eefa163"
  notifies :run, "execute[osmium-make-install]", :immediate
end

# make OSM-binary for protobuf support
execute "osm-binary-make-install" do
  action :nothing
  command "make -C src all install"
  cwd osm_binary_srcdir
end

# the OSM-binary makefile doesn't like to install over the
# top of an existing install.
execute "osm-binary-cleanup" do
  action :nothing
  command "rm -rf /usr/local/lib/libosmpbf.* /usr/local/include/osmpbf"
  cwd osm_binary_srcdir
end

git osm_binary_srcdir do
  repository "https://github.com/scrosby/OSM-binary.git"
  revision "master"
  notifies :run, "execute[osm-binary-cleanup]", :immediate
  notifies :run, "execute[osm-binary-make-install]", :immediate
end

# make MaZderMind"s history splitting tool
execute "osm-history-splitter-install" do
  action :nothing
  command "cp osm-history-splitter /usr/local/bin"
  cwd osm_history_splitter_srcdir
end

execute "osm-history-splitter-make" do
  action :nothing
  command "make CXX='g++ -std=c++11'"
  cwd osm_history_splitter_srcdir
  notifies :run, "execute[osm-history-splitter-install]", :immediate
end

git osm_history_splitter_srcdir do
  repository "https://github.com/MaZderMind/osm-history-splitter.git"
  revision "e496e375a3080351b86c968661f90dc3f2c626b0"
  notifies :run, "execute[osm-history-splitter-make]", :immediate
end

# libosmium (the new library)
git libosmium_srcdir do
  repository "https://github.com/zerebubuth/libosmium.git"
  revision "65d31e9035ca4ec79aa6a337b78c974c4434b06c"
end

# osmium-tool
execute "osmium-tool-make-install" do
  action :nothing
  command "make install"
  cwd "#{osmium_tool_srcdir}/build"
end

execute "osmium-tool-cmake" do
  action :nothing
  command "cmake -DOSMIUM_INCLUDE_DIR:PATH='#{libosmium_srcdir}/include' .."
  cwd "#{osmium_tool_srcdir}/build"
  notifies :run, "execute[osmium-tool-make-install]", :immediate
end

directory "#{osmium_tool_srcdir}/build" do
  action :nothing
  owner "root"
  group "root"
  mode "0755"
end

git osmium_tool_srcdir do
  repository "https://github.com/osmcode/osmium-tool.git"
  revision "v1.2.1"
  notifies :create, "directory[#{osmium_tool_srcdir}/build]", :immediate
  notifies :run, "execute[osmium-tool-cmake]", :immediate
end

