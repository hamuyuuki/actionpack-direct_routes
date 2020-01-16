# frozen_string_literal: true

require_relative "route_set/url_helpers"

module ActionDispatch
  module Routing
    module DirectRoutes
      module UrlFor
        def self.included(url_for_module)
          url_for_module.module_exec { alias full_url_for url_for  }
        end

        def route_for(name, *args)
          public_send(:"#{name}_url", *args)
        end
      end
    end
  end
end
