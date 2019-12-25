# frozen_string_literal: true

require "test_helper"

require "active_support"
require "active_support/test_case"
require "active_support/testing/autorun"

require "action_controller"
require "action_controller/test_case"

require "rack/test"

class RoutingTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::Isolation
  include Rack::Test::Methods

  def app_path
    @app_path ||= Dir.mktmpdir("direct_routes-")
  end

  def app_template_path
    @app_template_path ||= File.join(File.expand_path("../", __dir__), "dummy")
  end

  def app_file(path, contents, mode = 'w')
    FileUtils.mkdir_p File.dirname("#{app_path}/#{path}")
    File.open("#{app_path}/#{path}", mode) do |f|
      f.puts contents
    end
  end

  def app(env = "production")
    old_env = ENV["RAILS_ENV"]
    @app ||= begin
      ENV["RAILS_ENV"] = env
      require "#{app_path}/config/environment"
      Rails.application
    end
  ensure
    ENV["RAILS_ENV"] = old_env
  end

  def controller(name, contents)
    app_file("app/controllers/#{name}_controller.rb", contents)
  end

  def setup
    FileUtils.cp_r(Dir.glob("#{app_template_path}/*"), app_path)
  end

  def teardown
    FileUtils.rm_rf(app_path)
  end

  {
    "development" => ["baz", "http://www.apple.com", "/dashboard"],
    "production"  => ["bar", "http://www.microsoft.com", "/profile"]
  }.each do |mode, (expected_action, expected_url, expected_mapping)|
    test "reloads routes when configuration is changed in #{mode}" do
      controller :foo, <<-RUBY
        class FooController < ApplicationController
          def custom
            render plain: custom_url
          end
        end
      RUBY

      app_file "config/routes.rb", <<-RUBY
        Rails.application.routes.draw do
          get 'custom', to: 'foo#custom'

          direct(:custom) { "http://www.microsoft.com" }
        end
      RUBY

      app(mode)

      get "/custom"
      assert_equal "http://www.microsoft.com", last_response.body

      app_file "config/routes.rb", <<-RUBY
        Rails.application.routes.draw do
          get 'custom', to: 'foo#custom'

          direct(:custom) { "http://www.apple.com" }
        end
      RUBY

      sleep 0.1

      get "/custom"
      assert_equal expected_url, last_response.body
    end
  end

  test "routes are added and removed when reloading" do
    app("development")

    controller :foo, <<-RUBY
      class FooController < ApplicationController
        def index
          render plain: "foo"
        end

        def custom
          render plain: custom_url
        end
      end
    RUBY

    controller :bar, <<-RUBY
      class BarController < ApplicationController
        def index
          render plain: "bar"
        end
      end
    RUBY

    app_file "config/routes.rb", <<-RUBY
      Rails.application.routes.draw do
        get 'foo', to: 'foo#index'
      end
    RUBY

    get "/foo"
    assert_equal "foo", last_response.body
    assert_equal "/foo", Rails.application.routes.url_helpers.foo_path

    get "/bar"
    assert_equal 404, last_response.status
    assert_raises NoMethodError do
      assert_equal "/bar", Rails.application.routes.url_helpers.bar_path
    end

    app_file "config/routes.rb", <<-RUBY
      Rails.application.routes.draw do
        get 'foo', to: 'foo#index'
        get 'bar', to: 'bar#index'

        get 'custom', to: 'foo#custom'
        direct(:custom) { 'http://www.apple.com' }
      end
    RUBY

    Rails.application.reload_routes!

    get "/foo"
    assert_equal "foo", last_response.body
    assert_equal "/foo", Rails.application.routes.url_helpers.foo_path

    get "/bar"
    assert_equal "bar", last_response.body
    assert_equal "/bar", Rails.application.routes.url_helpers.bar_path

    get "/custom"
    assert_equal "http://www.apple.com", last_response.body
    assert_equal "http://www.apple.com", Rails.application.routes.url_helpers.custom_url

    app_file "config/routes.rb", <<-RUBY
      Rails.application.routes.draw do
        get 'foo', to: 'foo#index'
      end
    RUBY

    Rails.application.reload_routes!

    get "/foo"
    assert_equal "foo", last_response.body
    assert_equal "/foo", Rails.application.routes.url_helpers.foo_path

    get "/bar"
    assert_equal 404, last_response.status
    assert_raises NoMethodError do
      assert_equal "/bar", Rails.application.routes.url_helpers.bar_path
    end

    get "/custom"
    assert_equal 404, last_response.status
    assert_raises NoMethodError do
      assert_equal "http://www.apple.com", Rails.application.routes.url_helpers.custom_url
    end
  end

  test "named routes are cleared when reloading" do
    app_file "config/routes.rb", <<-RUBY
      Rails.application.routes.draw do
        direct(:microsoft) { 'http://www.microsoft.com' }
      end
    RUBY

    app("development")

    assert_equal "http://www.microsoft.com", Rails.application.routes.url_helpers.microsoft_url

    app_file "config/routes.rb", <<-RUBY
      Rails.application.routes.draw do
        direct(:apple) { 'http://www.apple.com' }
      end
    RUBY

    Rails.application.reload_routes!

    assert_equal "http://www.apple.com", Rails.application.routes.url_helpers.apple_url

    assert_raises NoMethodError do
      assert_equal "http://www.microsoft.com", Rails.application.routes.url_helpers.microsoft_url
    end
  end
end
