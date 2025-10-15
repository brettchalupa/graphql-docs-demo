# GraphQL Books API Demo

![CI](https://github.com/brettchalupa/graphql-docs-demo/workflows/CI/badge.svg)

> **This is a sample/demonstration project for the [graphql-docs](https://rubygems.org/gems/graphql-docs) gem ([GitHub](https://github.com/brettchalupa/graphql-docs)).**

This project provides a complete, working example of a GraphQL API built with [graphql-ruby](https://graphql-ruby.org/) and Sinatra, specifically designed to showcase how easy it is to integrate and use the **[graphql-docs](https://github.com/brettchalupa/graphql-docs)** gem to automatically generate beautiful, comprehensive documentation for your GraphQL APIs.

**graphql-docs gem:** [RubyGems](https://rubygems.org/gems/graphql-docs) | [GitHub](https://github.com/brettchalupa/graphql-docs)

**This is a sample project.** It demonstrates best practices for integrating graphql-docs into a Ruby GraphQL application.

## What is graphql-docs?

graphql-docs is a Ruby gem that automatically generates beautiful, static HTML documentation from your GraphQL schema. It creates searchable, navigable documentation for all your types, queries, mutations, and fields - no manual documentation writing required!

## Quick Start

```bash
# Clone and install
git clone <this-repo>
cd graphql-docs-demo
bundle install

# Generate documentation
bundle exec rake docs

# View the documentation
open docs/index.html  # macOS
xdg-open docs/index.html  # Linux
```

That's it! You now have comprehensive, searchable documentation for the entire GraphQL API.

## Why This Demo?

This demo shows everything you need to integrate graphql-docs into your own project:

- ✅ **Complete working GraphQL API** with queries and mutations
- ✅ **Full graphql-docs integration** (see `Rakefile:40-54`)
- ✅ **Generated documentation examples** in the `docs/` directory
- ✅ **Best practices** for schema design and documentation
- ✅ **Production-ready setup** with tests and linting

## The API (Demo Context)

This demo implements a Books API with classic literature:

**Types:**

- `Book` - Classic book with title, author, slug, description, genre, pages, and read count

**Queries:**

- `books` - Get all books
- `book(slug:)` - Get a specific book by slug

**Mutations:**

- `markAsRead(slug:)` - Mark a book as read (increments read count)

## How to Integrate graphql-docs Into Your Project

This demo shows the **Ruby API approach** (using `GraphQLDocs.build` in a Rake task), but graphql-docs also supports:

- **CLI approach** - Use the `graphql-docs` command with a dumped `.graphql` schema file
- **Direct Ruby integration** - Call `GraphQLDocs.build` from anywhere in your code

### Ruby API Approach (This Demo)

### Step 1: Add the Gem

Add to your `Gemfile`:

**From RubyGems (stable):**

```ruby
gem "graphql-docs", "~> 5.0"
```

**From GitHub (latest, as used in this demo):**

```ruby
gem "graphql-docs", github: "brettchalupa/graphql-docs", branch: "main"
```

Then run:

```bash
bundle install
```

**Note:** This demo uses the GitHub `main` branch to showcase the latest features.

### Step 2: Create a Rake Task

Add to your `Rakefile` (or create one):

```ruby
desc "Generate GraphQL documentation using graphql-docs"
task :docs do
  require_relative "schema"  # Load your schema file
  require "graphql-docs"

  GraphQLDocs.build(
    schema: BooksSchema,      # Replace with your schema class
    output_dir: "./docs",     # Where to generate docs
    delete_output: true,      # Clean before generating
    base_url: "/docs"         # Base URL for links
  )

  puts "Documentation generated in ./docs"
end
```

**That's the entire integration!** See it in action in this repo at `Rakefile:40-54`.

### Step 3: Generate Documentation

Run the task:

```bash
bundle exec rake docs
```

### Step 4: View the Documentation

Open `docs/index.html` in your browser directly, or:

**Option 1: Use this demo's Sinatra app (already configured!)**

```bash
bundle exec rake server
# Visit http://localhost:4567/docs/
```

**Option 2: Serve with Ruby's built-in HTTP server**

```bash
ruby -run -e httpd docs -p 8000
# Visit http://localhost:8000
```

## What Gets Generated

The gem creates a complete documentation site with:

- **Schema overview** - Complete API reference at `docs/index.html`
- **Object types** - Detailed pages for each type (e.g., `docs/object/book/index.html`)
- **Queries** - Documentation for all query operations
- **Mutations** - Documentation for all mutations
- **Scalars, Enums, Interfaces** - Complete type system documentation
- **Search functionality** - Find types and fields quickly
- **Navigation sidebar** - Easy browsing between types

### Example Output Structure

For our Books API, graphql-docs generates:

```
docs/
├── index.html              # Schema overview
├── object/
│   └── book/
│       └── index.html      # Book type documentation
├── query/
│   ├── books/
│   │   └── index.html      # books query
│   └── book/
│       └── index.html      # book(slug:) query
├── mutation/
│   └── markasread/
│       └── index.html      # markAsRead mutation
├── scalar/
│   ├── string/
│   ├── int/
│   └── ...
└── assets/                 # CSS, JS, images
    └── ...
```

## Configuration Options

The `GraphQLDocs.build` method accepts many options for customization:

### Basic Options

```ruby
GraphQLDocs.build(
  schema: YourSchema,           # Required: Your GraphQL::Schema class
  output_dir: "./docs",         # Where to output files
  delete_output: true,          # Clean output dir first
  base_url: "/docs"             # Base URL for links
)
```

### Advanced Options

```ruby
GraphQLDocs.build(
  schema: YourSchema,
  output_dir: "./docs",

  # Custom landing page content
  landing_pages: {
    index: File.read("./docs_templates/index.md")
  },

  # Custom templates for styling
  templates: {
    default: "./docs_templates/default.erb"
  },

  # Customize which types to document
  only: [:object, :query, :mutation],

  # Exclude specific types
  except: [:__Directive, :__Schema]
)
```

See the [graphql-docs documentation](https://github.com/brettchalupa/graphql-docs/) for all available options.

### Alternative: CLI Approach

If you prefer not to use the Ruby API, you can use the CLI with a dumped schema:

**1. Dump your schema to a file:**

This demo includes a `schema:dump` task:

```bash
bundle exec rake schema:dump
```

Or do it manually:

```bash
ruby -e "require_relative 'schema'; puts BooksSchema.to_definition" > schema.graphql
```

**2. Generate docs with the CLI:**

```bash
bundle exec graphql-docs schema.graphql --output docs
```

This is useful for CI/CD pipelines or when you don't want to load your entire application just to generate docs.

## Tips for Better Documentation

1. **Add descriptions** - Use the `description:` parameter on fields, types, and arguments in your schema
2. **Document deprecations** - Use `deprecation_reason:` for deprecated fields
3. **Group related types** - Use consistent naming conventions
4. **Keep it updated** - Regenerate docs after schema changes (add to CI/CD)

Example with good descriptions:

```ruby
field :book, BookType, null: true, description: "Fetch a single book by its unique slug identifier" do
  argument :slug, String, required: true, description: "The URL-friendly slug for the book (e.g., 'pride-and-prejudice')"
end
```

## Deploying Documentation

The generated docs are static HTML, so you can:

- **Commit to repo** - Version with your code
- **Deploy to GitHub Pages** - Free hosting for public repos
- **Upload to S3/CDN** - Fast global delivery
- **Serve from your app** - Integrate with your Rails/Sinatra app

### Example: Serving from Sinatra

This demo already serves the docs at `/docs/`! See the implementation in `app.rb:31-48`:

```ruby
# Serve generated GraphQL documentation
get "/docs/?*" do
  # Handle the splat parameter to build the file path
  path = params["splat"]&.first || ""
  file_path = File.join("docs", path)

  # If it's a directory, serve index.html
  if File.directory?(file_path)
    file_path = File.join(file_path, "index.html")
  end

  # Serve the file if it exists
  if File.exist?(file_path)
    send_file file_path
  else
    halt 404, "Documentation not found. Run 'rake docs' to generate it."
  end
end
```

Just start the server and visit `http://localhost:4567/docs/`

---

## Running This Demo

### Prerequisites

- Ruby 3.0 or higher
- Bundler

### Installation

```bash
git clone <this-repo>
cd graphql-docs-demo
bundle install
```

### Running the Server

Start the GraphQL API server:

```bash
bundle exec rake server
# or: bundle exec ruby app.rb
```

Then visit:

- `http://localhost:4567` - Interactive GraphQL playground
- `http://localhost:4567/docs/` - Generated API documentation (after running `rake docs`)

### Example Queries

**Get all books:**

```graphql
query {
  books {
    title
    author
    slug
    readCount
  }
}
```

**Get a specific book:**

```graphql
query {
  book(slug: "pride-and-prejudice") {
    title
    author
    publishedYear
    description
    genre
    pages
    readCount
  }
}
```

**Mark a book as read:**

```graphql
mutation {
  markAsRead(slug: "1984") {
    title
    author
    readCount
  }
}
```

### Using curl

```bash
curl -X POST http://localhost:4567/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "{ books { title author } }"}'
```

## Development

### Rake Tasks

```bash
# Run tests and linter (default task)
bundle exec rake

# Run tests only
bundle exec rake test

# Run linter only
bundle exec rake lint

# Auto-fix linting issues
bundle exec rake lint_fix

# Start the server
bundle exec rake server

# Dump GraphQL schema to schema.graphql file
bundle exec rake schema:dump

# Generate GraphQL documentation (the main point!)
bundle exec rake docs
```

### Linting

This project uses [StandardRB](https://github.com/standardrb/standard) for Ruby style enforcement.

### Continuous Integration

This project includes a GitHub Actions workflow (`.github/workflows/ci.yml`) that runs on every push and pull request:

- ✅ Runs all tests
- ✅ Runs StandardRB linter
- ✅ Dumps GraphQL schema
- ✅ Generates documentation
- ✅ Uploads artifacts (schema + docs)

This ensures the graphql-docs integration stays working and demonstrates a complete CI/CD setup.

### Testing

Comprehensive test suite with Minitest (Ruby stdlib) and Rack::Test:

```bash
bundle exec rake test
```

- 11 tests, 78 assertions
- Tests queries, mutations, read counts, docs serving, and error handling

## Project Structure

```
.
├── app.rb                   # Sinatra app with GraphQL endpoint + playground
├── schema.rb                # GraphQL schema (types, queries, mutations)
├── data/books.yml           # Books database (YAML)
├── test/graphql_test.rb     # Test suite
├── Rakefile                 # Rake tasks including 'docs' task ⭐
├── Gemfile                  # Dependencies including graphql-docs gem ⭐
├── docs/                    # Generated documentation (run 'rake docs') ⭐
└── README.md                # You are here!
```

Files marked with ⭐ are the key integration points for graphql-docs.

## Learn More

- [graphql-docs GitHub Repository](https://github.com/brettchalupa/graphql-docs/)
- [graphql-ruby Documentation](https://graphql-ruby.org/)
- [GraphQL Specification](https://spec.graphql.org/)

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

This is a demonstration project. Feel free to fork and modify for your own learning purposes!

---

**The entire purpose of this project is to demonstrate how easy it is to add comprehensive documentation to your GraphQL API using graphql-docs. Just add the gem, create a rake task, and run it!**

Try it now:

```bash
bundle exec rake docs
open docs/index.html
```
