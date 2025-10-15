# frozen_string_literal: true

require "rake/testtask"

# Default task runs tests and linter
desc "Run tests and linter"
task default: [:test, :lint]

# Test task
Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
end

# Linting task
desc "Run StandardRB linter"
task :lint do
  sh "bundle exec standardrb"
end

desc "Auto-fix StandardRB linting issues"
task :lint_fix do
  sh "bundle exec standardrb --fix"
end

desc "Start the Sinatra server"
task :serve do
  sh "bundle exec ruby app.rb"
end

desc "Start the server with Puma"
task :puma do
  sh "bundle exec puma app.rb"
end

namespace :schema do
  desc "Dump GraphQL schema to schema.graphql file"
  task :dump do
    require_relative "schema"

    File.write("schema.graphql", BooksSchema.to_definition)
    puts "Schema dumped to schema.graphql"
  end
end

# Documentation generation task
desc "Generate GraphQL documentation using graphql-docs"
task :docs do
  require_relative "schema"
  require "graphql-docs"

  GraphQLDocs.build(
    schema: BooksSchema,
    output_dir: "./docs",
    delete_output: true,
    base_url: "/docs"
  )

  puts "Documentation generated in ./docs"
end
