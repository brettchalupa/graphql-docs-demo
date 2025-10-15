# frozen_string_literal: true

source "https://rubygems.org"

ruby "3.4.5"

gem "sinatra", "~> 4.2"
gem "graphql", "~> 2.4"

# Using graphql-docs from GitHub main branch
gem "graphql-docs", github: "brettchalupa/graphql-docs", branch: "main"

gem "rackup", "~> 2.2"
gem "puma", "~> 7.0"
gem "rake", "~> 13.2"

group :development do
  gem "standard", "~> 1.45"
end

group :test do
  gem "rack-test", "~> 2.1"
  gem "minitest", "~> 5.25"
end
