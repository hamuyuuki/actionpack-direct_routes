# frozen_string_literal: true

module ActionDispatch
  module Routing
    module DirectRoutes
      module Mapper
        module Scope
          def root?
            @parent == {}
          end
        end
      end
    end
  end
end
