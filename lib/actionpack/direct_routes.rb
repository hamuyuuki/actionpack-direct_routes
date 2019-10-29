# frozen_string_literal: true

require "active_support/lazy_load_hooks"

ActiveSupport.on_load(:before_initialize) do
  require "action_dispatch/routing/direct_routes/mapper"
  require "action_dispatch/routing/direct_routes/mapper/scope"
  require "action_dispatch/routing/direct_routes/route_set"
  require "action_dispatch/routing/direct_routes/route_set/named_route_collection"

  ActionDispatch::Routing::Mapper.include(ActionDispatch::Routing::DirectRoutes::Mapper)
  ActionDispatch::Routing::Mapper::Scope.include(ActionDispatch::Routing::DirectRoutes::Mapper::Scope)
  ActionDispatch::Routing::RouteSet.prepend(ActionDispatch::Routing::DirectRoutes::RouteSet)
  ActionDispatch::Routing::RouteSet::NamedRouteCollection.include(ActionDispatch::Routing::DirectRoutes::RouteSet::NamedRouteCollection)
end
