#
# Cookbook Name:: unbound-build
# Library:: unarchive
#
# Copyright (C) 2015 John Manero
#
# TODO: MIT License
#
require 'digest'
require 'fileutils'
require 'rubygems'
require 'rubygems/package'
require 'zlib'

class Chef
  class Resource
    ##
    # Implementation of gunzip/untar from https://gist.github.com/sinisterchipmunk/1335041
    ##
    class Unarchive < Chef::Resource
      resource_name :unarchive
      attr_writer :extracted
      def initialize(name, run_context = nil)
        super

        ## Actions
        @action = [:unzip, :untar]
        @allowed_actions << :untar
        @allowed_actions << :uncompress

        ## State
        @extracted = false
        @temp_file = nil
      end

      def extracted? # rubocop:disable Style/TrivialAccessors
        @extracted
      end

      def untar?
        @action.include?(:untar)
      end

      def unzip?
        @action.include?(:unzip)
      end

      ## Attributes
      def source(arg = nil)
        set_or_return(:source, arg, :kind_of => String,
                                    :name_attribute => true)
      end

      def destination(arg = nil)
        set_or_return(:destination, arg, :kind_of => String,
                                         :required => true)
      end

      def owner(arg = nil)
        set_or_return(:owner, arg, :kind_of => String)
      end

      def group(arg = nil)
        set_or_return(:group, arg, :kind_of => String)
      end

      def temp_file
        @temp_file ||= ::File.join(Chef::Config[:file_cache_path], "unarchive-#{ Digest::MD5.file(source).hexdigest }.tar")
      end

      ## Is a temp_file required?
      def untar_source
        return source unless unzip?
        temp_file
      end

      def unzip_destination
        return destination unless untar?
        temp_file
      end
    end
  end

  class Provider
    ##
    # Implementation of gunzip/untar from https://gist.github.com/sinisterchipmunk/1335041
    ##
    class Unarchive < Chef::Provider::LWRPBase
      use_inline_resources

      def load_current_resource
        new_resource
      end

      ## Stub action methods. The `extract` method will check `@actions` and
      ## ececute them in the correct order.
      def action_untar
        extract
      end

      def action_unzip
        extract
      end

      def extract
        return if new_resource.extracted?

        unzip if new_resource.unzip?
        untar if new_resource.untar?

        new_resource.extracted = true
      end

      def untar
        Chef::Log.info("unarchive[#{ new_resource.name }]: Untar #{ new_resource.untar_source } to #{ new_resource.destination }")

        ::File.open(new_resource.untar_source) do |f|
          Gem::Package::TarReader.new(f) do |tar|
            ## We need to interate over the TAR twice. First to create directories,
            ## Then to create files and links
            tar.each do |entry|
              next unless entry.directory?

              directory ::File.join(new_resource.destination, entry.full_name) do
                recursive true
                owner new_resource.owner
                group new_resource.group
                mode entry.header.mode
              end
            end

            tar.rewind
            tar.each do |entry|
              next if entry.directory?
              entry_path = ::File.join(new_resource.destination, entry.full_name)

              file entry_path do
                content entry.read
                owner new_resource.owner
                group new_resource.group
                mode entry.header.mode
                only_if { entry.header.typeflag == '0' }
              end

              link entry_path do
                to entry.header.linkname
                owner new_resource.owner
                group new_resource.group
                mode entry.header.mode
                only_if { entry.header.typeflag == '2' }
              end
            end
          end
        end

        Chef::Log.info("unarchive[#{ new_resource.name }]: Untared #{ new_resource.untar_source } to #{ new_resource.destination }")
      end

      def unzip
        Chef::Log.info("unarchive[#{ new_resource.name }]: Unzip #{ new_resource.source } to #{ new_resource.unzip_destination }")

        ## Don't re-extract the same source
        return if ::File.exist?(new_resource.unzip_destination)

        Zlib::GzipReader.open(new_resource.source) do |gz|
          ::File.open(new_resource.unzip_destination, 'wb') { |f| f.write(gz.read) }
        end

        Chef::Log.info("unarchive[#{ new_resource.name }]: Unzipped #{ new_resource.source } to #{ new_resource.unzip_destination }")
      end
    end
  end
end
