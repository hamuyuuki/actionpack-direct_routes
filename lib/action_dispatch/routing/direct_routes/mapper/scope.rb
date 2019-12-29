# frozen_string_literal: true

module ActionDispatch
  module Routing
    module DirectRoutes
      module Mapper
        module Scope
          def null?
            @hash.nil? && @parent.nil?
          end

          def root?
            @parent == {} || @parent.null?
          end
        end
      end
    end
  end
end
