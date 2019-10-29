# frozen_string_literal: true

module ActionDispatch
  module Routing
    module DirectRoutes
      module Mapper
        def direct(name, options = {}, &block)
          unless @scope.root?
            raise RuntimeError, "The direct method can't be used inside a routes scope block"
          end

          @set.add_url_helper(name, options, &block)
        end
      end
    end
  end
end
