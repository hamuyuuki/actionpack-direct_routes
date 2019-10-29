# frozen_string_literal: true

module ActionDispatch
  module Routing
    module DirectRoutes
      module RouteSet
        def add_url_helper(name, options, &block)
          named_routes.add_url_helper(name, options, &block)
        end

        def url_helpers(supports_path = true)
          routes = self

          Module.new do
            extend ActiveSupport::Concern
            include ActionDispatch::Routing::UrlFor

            # Define url_for in the singleton level so one can do:
            # Rails.application.routes.url_helpers.url_for(args)
            proxy_class = Class.new do
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

            @_proxy = proxy_class.new(routes)

            class << self
              def url_for(options)
                @_proxy.url_for(options)
              end

              def optimize_routes_generation?
                @_proxy.optimize_routes_generation?
              end

              def _routes; @_proxy._routes; end
              def url_options; {}; end
            end

            url_helpers = routes.named_routes.url_helpers_module

            # Make named_routes available in the module singleton
            # as well, so one can do:
            # Rails.application.routes.url_helpers.posts_path
            extend url_helpers

            # Any class that includes this module will get all
            # named routes...
            include url_helpers

            if supports_path
              path_helpers = routes.named_routes.path_helpers_module

              include path_helpers
              extend path_helpers
            end

            # plus a singleton class method called _routes ...
            included do
              singleton_class.send(:redefine_method, :_routes) { routes }
            end

            # And an instance method _routes. Note that
            # UrlFor (included in this module) add extra
            # conveniences for working with @_routes.
            define_method(:_routes) { @_routes || routes }

            define_method(:_generate_paths_by_default) do
              supports_path
            end

            private :_generate_paths_by_default
          end
        end
      end
    end
  end
end
