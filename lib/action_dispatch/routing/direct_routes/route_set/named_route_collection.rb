# frozen_string_literal: true

require_relative "custom_url_helper"

module ActionDispatch
  module Routing
    module DirectRoutes
      module RouteSet
        module NamedRouteCollection
          def add_url_helper(name, defaults, &block)
            helper = CustomUrlHelper.new(name, defaults, &block)
            path_name = :"#{name}_path"
            url_name = :"#{name}_url"

            @path_helpers_module.module_eval do
              redefine_method(path_name) do |*args|
                helper.call(self, args, true)
              end
            end

            @url_helpers_module.module_eval do
              redefine_method(url_name) do |*args|
                helper.call(self, args, false)
              end
            end

            @path_helpers << path_name
            @url_helpers << url_name

            self
          end
        end
      end
    end
  end
end
