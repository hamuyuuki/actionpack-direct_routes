# frozen_string_literal: true

module ActionDispatch
  module Routing
    module DirectRoutes
      module RouteSet
        module UrlHelpers
          def url_for(options)
            proxy.url_for(options)
          end

          def full_url_for(options)
            proxy.full_url_for(options)
          end

          def route_for(name, *args)
            proxy.route_for(name, *args)
          end

          def optimize_routes_generation?
            proxy.optimize_routes_generation?
          end

          def _routes; proxy._routes; end
          def url_options; {}; end

          private
            def proxy
              @proxy ||= proxy_class.new(@_routes)
            end

            def proxy_class
              routes = @_routes

              Class.new do
                include ActionDispatch::Routing::UrlFor
                include routes.named_routes.path_helpers_module
                include routes.named_routes.url_helpers_module

                attr_reader :_routes

                def initialize(routes)
                  @_routes = routes
                end

                def optimize_routes_generation?
                  @_routes.optimize_routes_generation?
                end
              end
            end
        end
      end
    end
  end
end
