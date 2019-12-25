# frozen_string_literal: true

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
require "minitest"
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

if ENV["CI"]
  require "simplecov"
  SimpleCov.start "rails" do
    add_filter "/test/"
  end
end
