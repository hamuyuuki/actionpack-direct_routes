# frozen_string_literal: true

require_relative "route_set/url_helpers"

module ActionDispatch
  module Routing
    module DirectRoutes
      module RouteSet
        def add_url_helper(name, options, &block)
          named_routes.add_url_helper(name, options, &block)
        end

        def url_helpers(supports_path = true)
          super_module = super(supports_path)
          super_module.singleton_class.prepend(RouteSet::UrlHelpers)

          super_module
        end
      end
    end
  end
end
