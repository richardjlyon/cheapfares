require "bundler/setup" # ensure we're loading Gemfile defined gems
require File.dirname(__FILE__) + '/../lib/cheapfares.rb'

# Enforce RSpec Expectation syntax
RSpec.configure do |config|
  # ...
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
