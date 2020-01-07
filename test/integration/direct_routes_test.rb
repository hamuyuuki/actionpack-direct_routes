# frozen_string_literal: true

require "test_helper"

require File.expand_path("../../../test/dummy/config/environment.rb",  __FILE__)
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../../../test/dummy/db/migrate", __FILE__)]
require "rails/test_help"

class DirectRoutesTest < ActionView::TestCase
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

  Routes = ActionDispatch::Routing::RouteSet.new
  Routes.draw do
    resources :categories, :collections, :products
    direct(:linkable) { |linkable| [:"#{linkable.linkable_type}", { id: linkable.id }] }
  end

  include Routes.url_helpers

  def setup
    @category = Category.new("1")
    @collection = Collection.new("2")
    @product = Product.new("3")
  end

  def test_direct_routes
    assert_equal "/categories/1", linkable_path(@category)
    assert_equal "/collections/2", linkable_path(@collection)
    assert_equal "/products/3", linkable_path(@product)

    assert_equal "http://test.host/categories/1", linkable_url(@category)
    assert_equal "http://test.host/collections/2", linkable_url(@collection)
    assert_equal "http://test.host/products/3", linkable_url(@product)
  end
end
