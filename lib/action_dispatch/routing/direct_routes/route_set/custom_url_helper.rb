# frozen_string_literal: true

module ActionDispatch
  module Routing
    module DirectRoutes
      module RouteSet
        class CustomUrlHelper
          attr_reader :name, :defaults, :block

          def initialize(name, defaults, &block)
            @name = name
            @defaults = defaults
            @block = block
          end

          def call(t, args, only_path = false)
            options = args.extract_options!
            url = t.url_for(eval_block(t, args, options))

            if only_path
              "/" + url.partition(%r{(?<!/)/(?!/)}).last
            else
              url
            end
          end

          private
            def eval_block(t, args, options)
              t.instance_exec(*args, merge_defaults(options), &block)
            end

            def merge_defaults(options)
              defaults ? defaults.merge(options) : options
            end
        end
      end
    end
  end
end
