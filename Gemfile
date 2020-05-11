# frozen_string_literal: true

# source "https://rubygems.org"
source 'https://gems.ruby-china.com'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Declare your gem's dependencies in flow_core.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use a debugger
gem "byebug", group: %i[development test]

# Use Puma as the app server
gem "puma"
# Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
gem "listen", ">= 3.0.5", "< 3.2"
gem "web-console", group: :development

gem "rubocop"
gem "rubocop-performance"
gem "rubocop-rails"

gem "dentaku"
gem "kaminari"
gem "validates_timeliness", "~> 5.0.0.alpha4"

# Support ES6
gem "babel-transpiler"
# Use SCSS for stylesheets
gem "sassc-rails"

gem "bootstrap", "~> 4.4"
gem "jquery-rails"
gem "turbolinks"

gem "ruby-graphviz", require: "graphviz"
