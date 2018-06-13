require 'fluent/event'
require 'fluent/plugin/filter'

require 'fluent/plugin/asresolver_pool'

module Fluent
  module Plugin
    class AsresolverFilter < Filter
      Fluent::Plugin.register_filter('asresolver', self)

      config_param :grpc, :string, default: 'localhost:50051',
                   desc: 'gRPC host and port string where gobgpd is listening'
      config_param :threads, :integer, default: 2,
                   desc: 'Number of threads to consult gobgpd'

      def configure(conf)
        super
        @pool = AsresolverPool.new(self)
      end

      def filter(tag, time, record)
        @pool.resolve(record)
      end
    end
  end
end