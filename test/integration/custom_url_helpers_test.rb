# frozen_string_literal: true

require "test_helper"

require File.expand_path("../../../test/dummy/config/environment.rb",  __FILE__)
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../../../test/dummy/db/migrate", __FILE__)]
require "rails/test_help"

class CustomUrlHelpersTest < ActionDispatch::IntegrationTest
  class Linkable
    attr_reader :id

    def self.name
      super.demodulize
    end

    def initialize(id)
      @id = id
    end

    def linkable_type
      self.class.name.underscore
    end
  end

  class Category < Linkable; end
  class Collection < Linkable; end
  class Product < Linkable; end

  class Model
    extend ActiveModel::Naming
    include ActiveModel::Conversion

    attr_reader :id

    def initialize(id = nil)
      @id = id
    end

    remove_method :model_name
    def model_name
      @_model_name ||= ActiveModel::Name.new(self.class, nil, self.class.name.demodulize)
    end

    def persisted?
      false
    end
  end

  class Basket < Model; end
  class User < Model; end

  class Article
    attr_reader :id

    def self.name
      "Article"
    end

    def initialize(id)
      @id = id
    end
  end

  class Page
    attr_reader :id

    def self.name
      super.demodulize
    end

    def initialize(id)
      @id = id
    end
  end

  class RoutedRackApp
    attr_reader :routes

    def initialize(routes)
      @routes = routes
      @stack = ActionDispatch::MiddlewareStack.new.build(@routes)
    end

    def call(env)
      @stack.call(env)
    end
  end

  Routes = ActionDispatch::Routing::RouteSet.new
  Routes.draw do
    default_url_options host: "www.example.com"

    root to: "pages#index"
    get "/basket", to: "basket#show", as: :basket
    get "/posts/:id", to: "posts#show", as: :post
    get "/profile", to: "users#profile", as: :profile
    get "/media/:id", to: "media#show", as: :media
    get "/pages/:id", to: "pages#show", as: :page

    resources :categories, :collections, :products

    namespace :admin do
      get "/dashboard", to: "dashboard#index"
    end

    direct(:website)  { "http://www.rubyonrails.org" }
    direct("string")  { "http://www.rubyonrails.org" }
    direct(:helper)   { basket_url }
    direct(:linkable) { |linkable| [:"#{linkable.linkable_type}", { id: linkable.id }] }
    direct(:params)   { |params| params }
    direct(:symbol)   { :basket }
    direct(:hash)     { { controller: "basket", action: "show" } }
    direct(:array)    { [:admin, :dashboard] }
    direct(:options)  { |options| [:products, options] }
    direct(:defaults, size: 10) { |options| [:products, options] }

    direct(:browse, page: 1, size: 10) do |options|
      [:products, options.merge(params.permit(:page, :size).to_h.symbolize_keys)]
    end
  end

  APP = RoutedRackApp.new(Routes)
  def app
    APP
  end

  include Routes.url_helpers

  def setup
    @category = Category.new("1")
    @collection = Collection.new("2")
    @product = Product.new("3")
    @basket = Basket.new
    @user = User.new
    @page = Page.new("6")
    @path_params = { "controller" => "pages", "action" => "index" }
    @unsafe_params = ActionController::Parameters.new(@path_params)
    @safe_params = ActionController::Parameters.new(@path_params).permit(:controller, :action)
  end

  def params
    ActionController::Parameters.new(page: 2, size: 25)
  end

  def test_direct_paths
    assert_equal "/", website_path
    assert_equal "/", Routes.url_helpers.website_path

    assert_equal "/", string_path
    assert_equal "/", Routes.url_helpers.string_path

    assert_equal "/basket", helper_path
    assert_equal "/basket", Routes.url_helpers.helper_path

    assert_equal "/categories/1", linkable_path(@category)
    assert_equal "/categories/1", Routes.url_helpers.linkable_path(@category)
    assert_equal "/collections/2", linkable_path(@collection)
    assert_equal "/collections/2", Routes.url_helpers.linkable_path(@collection)
    assert_equal "/products/3", linkable_path(@product)
    assert_equal "/products/3", Routes.url_helpers.linkable_path(@product)

    assert_equal "/", params_path(@safe_params)
    assert_equal "/", Routes.url_helpers.params_path(@safe_params)

    if Rails::VERSION::MAJOR == 4 && Rails::VERSION::MINOR == 2
      assert_equal "/", params_path(@unsafe_params)
      assert_equal "/", Routes.url_helpers.params_path(@unsafe_params)
    elsif Rails::VERSION::MAJOR == 5 && Rails::VERSION::MINOR == 0
      assert_raises(ArgumentError) { params_path(@unsafe_params) }
      assert_raises(ArgumentError) { Routes.url_helpers.params_path(@unsafe_params) }
    end

    assert_equal "/basket", symbol_path
    assert_equal "/basket", Routes.url_helpers.symbol_path
    assert_equal "/basket", hash_path
    assert_equal "/basket", Routes.url_helpers.hash_path
    assert_equal "/admin/dashboard", array_path
    assert_equal "/admin/dashboard", Routes.url_helpers.array_path

    assert_equal "/products?page=2", options_path(page: 2)
    assert_equal "/products?page=2", Routes.url_helpers.options_path(page: 2)
    assert_equal "/products?size=10", defaults_path
    assert_equal "/products?size=10", Routes.url_helpers.defaults_path
    assert_equal "/products?size=20", defaults_path(size: 20)
    assert_equal "/products?size=20", Routes.url_helpers.defaults_path(size: 20)

    assert_equal "/products?page=2&size=25", browse_path
    assert_raises(NameError) { Routes.url_helpers.browse_path }
  end

  def test_direct_urls
    assert_equal "http://www.rubyonrails.org", website_url
    assert_equal "http://www.rubyonrails.org", Routes.url_helpers.website_url

    assert_equal "http://www.rubyonrails.org", string_url
    assert_equal "http://www.rubyonrails.org", Routes.url_helpers.string_url

    assert_equal "http://www.example.com/basket", helper_url
    assert_equal "http://www.example.com/basket", Routes.url_helpers.helper_url

    assert_equal "http://www.example.com/categories/1", linkable_url(@category)
    assert_equal "http://www.example.com/categories/1", Routes.url_helpers.linkable_url(@category)
    assert_equal "http://www.example.com/collections/2", linkable_url(@collection)
    assert_equal "http://www.example.com/collections/2", Routes.url_helpers.linkable_url(@collection)
    assert_equal "http://www.example.com/products/3", linkable_url(@product)
    assert_equal "http://www.example.com/products/3", Routes.url_helpers.linkable_url(@product)

    assert_equal "http://www.example.com/", params_url(@safe_params)
    assert_equal "http://www.example.com/", Routes.url_helpers.params_url(@safe_params)

    if Rails::VERSION::MAJOR == 4 && Rails::VERSION::MINOR == 2
      assert_equal "http://www.example.com/", params_url(@unsafe_params)
      assert_equal "http://www.example.com/", Routes.url_helpers.params_url(@unsafe_params)
    elsif Rails::VERSION::MAJOR == 5 && Rails::VERSION::MINOR == 0
      assert_raises(ArgumentError) { params_url(@unsafe_params) }
      assert_raises(ArgumentError) { Routes.url_helpers.params_url(@unsafe_params) }
    end

    assert_equal "http://www.example.com/basket", symbol_url
    assert_equal "http://www.example.com/basket", Routes.url_helpers.symbol_url
    assert_equal "http://www.example.com/basket", hash_url
    assert_equal "http://www.example.com/basket", Routes.url_helpers.hash_url
    assert_equal "http://www.example.com/admin/dashboard", array_url
    assert_equal "http://www.example.com/admin/dashboard", Routes.url_helpers.array_url

    assert_equal "http://www.example.com/products?page=2", options_url(page: 2)
    assert_equal "http://www.example.com/products?page=2", Routes.url_helpers.options_url(page: 2)
    assert_equal "http://www.example.com/products?size=10", defaults_url
    assert_equal "http://www.example.com/products?size=10", Routes.url_helpers.defaults_url
    assert_equal "http://www.example.com/products?size=20", defaults_url(size: 20)
    assert_equal "http://www.example.com/products?size=20", Routes.url_helpers.defaults_url(size: 20)

    assert_equal "http://www.example.com/products?page=2&size=25", browse_url
    assert_raises(NameError) { Routes.url_helpers.browse_url }
  end


  def test_defining_direct_inside_a_scope_raises_runtime_error
    routes = ActionDispatch::Routing::RouteSet.new

    assert_raises RuntimeError do
      routes.draw do
        namespace :admin do
          direct(:rubyonrails) { "http://www.rubyonrails.org" }
        end
      end
    end
  end

  def test_defining_direct_url_registers_helper_method
    assert_equal "http://www.example.com/basket", Routes.url_helpers.symbol_url
    assert_equal true, Routes.named_routes.route_defined?(:symbol_url), "'symbol_url' named helper not found"
    assert_equal true, Routes.named_routes.route_defined?(:symbol_path), "'symbol_path' named helper not found"
  end
end
