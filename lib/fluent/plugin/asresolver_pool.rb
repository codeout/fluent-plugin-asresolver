require 'ipaddr'
require 'thread'

require 'fluent/plugin/gobgp_pb'
require 'fluent/plugin/gobgp_services_pb'

module Fluent
  module Plugin
    class AsresolverPool
      def initialize(plugin)
        @log = plugin.log
        @grpc_target = plugin.grpc
        @threads = plugin.threads

        @pool = create_pool
      end

      def resolve(record)
        resolver = @pool.pop

        begin
          record = resolver.resolve(record)
        rescue
          @log.error 'Unexpected error', record: record, error_class: $!.class, error: $!.message, backtrace: $!.backtrace
        ensure
          @pool << resolver
        end
      end


      private

      def create_pool
        Queue.new.tap {|pool|
          @threads.times {pool << Asresolver.new(@grpc_target)}
        }
      end
    end


    class Asresolver
      def initialize(grpc_target)
        @grpc_target = grpc_target
      end

      def resolve(record)
        begin
          if (as = origin_as(record['src_ip'] || record['ipv4_src_addr'])) &&
              (record['src_as'].nil? || record['src_as'] == 0)
            record['src_as'] = as
          end

          if (as = origin_as(record['dst_ip'] || record['ipv4_dst_addr'])) &&
              (record['dst_as'].nil? || record['dst_as'] == 0)
            record['dst_as'] = as
          end
        rescue
          # NOTE: Skip without logging due to huge number of records
        end

        record
      end


      private

      # @param [String] ip
      # @reeturn [true|false]
      def ipv6?(ip)
        return ip.include?(':')
      end

      def stub
        @_stub ||= Gobgpapi::GobgpApi::Stub.new(@grpc_target, :this_channel_is_insecure)
      end

      # @param [String] prefix
      # @return [Integer|nil]
      def origin_as(prefix)
        # TODO: Support IPv6
        return nil if prefix.nil? || ipv6?(prefix)

        stub.get_rib(request([prefix])).table.destinations.map {|d|
          path_attrs = d.paths.find {|p| p.best}.pattrs.map {|i| i.unpack('C*')}
          as_path = path_attrs.find {|a| a[1] == 2}

          return nil unless as_path

          # NOTE: decode AS_PATH attribute
          case as_path[0]
          when 64 # 2 byte AS
            (as_path[-2] << 8) + as_path[-1]
          when 80 # 4 byte AS
            (as_path[-4] << 24) + (as_path[-3] << 16) + (as_path[-2] << 8) + as_path[-1]
          end
        }.first
      end

      def request(prefixes)
        Gobgpapi::GetRibRequest.new(
            table: Gobgpapi::Table::new(
                family: Gobgpapi::Family::IPv4,
                destinations: prefixes.map {|prefix| Gobgpapi::Destination.new(prefix: prefix)}
            )
        )
      end
    end
  end
end
