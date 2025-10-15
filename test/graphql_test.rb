require "minitest/autorun"
require "rack/test"
require "json"

ENV["RACK_ENV"] = "test"

require_relative "../app"

class GraphQLTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    # Reset read counts before each test
    READ_COUNTS.clear
  end

  def graphql_request(query, variables: nil)
    post "/graphql", {query: query, variables: variables}.to_json, {"CONTENT_TYPE" => "application/json"}
    JSON.parse(last_response.body)
  end

  def test_root_returns_html
    get "/"
    assert last_response.ok?
    assert_includes last_response.body, "graphql-docs"
    assert_includes last_response.body, "Automatic, beautiful documentation for your GraphQL APIs"
  end

  def test_docs_route_serves_documentation
    get "/docs/"
    # Should either serve the docs or return 404 with helpful message
    if File.exist?("docs/index.html")
      assert last_response.ok?
    else
      assert_equal 404, last_response.status
      assert_includes last_response.body, "rake docs"
    end
  end

  def test_books_query_returns_all_books
    query = <<~GRAPHQL
      query {
        books {
          title
          author
          slug
          readCount
        }
      }
    GRAPHQL

    result = graphql_request(query)

    assert_nil result["errors"]
    assert result["data"]["books"].is_a?(Array)
    assert_equal 10, result["data"]["books"].length

    # Check first book
    first_book = result["data"]["books"].first
    assert_equal "Pride and Prejudice", first_book["title"]
    assert_equal "Jane Austen", first_book["author"]
    assert_equal "pride-and-prejudice", first_book["slug"]
    assert_equal 0, first_book["readCount"]
  end

  def test_book_query_by_slug_returns_specific_book
    query = <<~GRAPHQL
      query {
        book(slug: "1984") {
          title
          author
          slug
          publishedYear
          description
          genre
          pages
          readCount
        }
      }
    GRAPHQL

    result = graphql_request(query)

    assert_nil result["errors"]
    book = result["data"]["book"]
    assert_equal "1984", book["title"]
    assert_equal "George Orwell", book["author"]
    assert_equal "1984", book["slug"]
    assert_equal 1949, book["publishedYear"]
    assert_equal "Dystopian Fiction", book["genre"]
    assert_equal 328, book["pages"]
    assert_equal 0, book["readCount"]
    assert_includes book["description"], "dystopian"
  end

  def test_book_query_with_invalid_slug_returns_null
    query = <<~GRAPHQL
      query {
        book(slug: "nonexistent-book") {
          title
        }
      }
    GRAPHQL

    result = graphql_request(query)

    assert_nil result["errors"]
    assert_nil result["data"]["book"]
  end

  def test_mark_as_read_mutation_increments_read_count
    mutation = <<~GRAPHQL
      mutation {
        markAsRead(slug: "pride-and-prejudice") {
          title
          readCount
        }
      }
    GRAPHQL

    result = graphql_request(mutation)

    assert_nil result["errors"]
    book = result["data"]["markAsRead"]
    assert_equal "Pride and Prejudice", book["title"]
    assert_equal 1, book["readCount"]

    # Query again to verify persistence
    query = <<~GRAPHQL
      query {
        book(slug: "pride-and-prejudice") {
          readCount
        }
      }
    GRAPHQL

    result2 = graphql_request(query)
    assert_equal 1, result2["data"]["book"]["readCount"]
  end

  def test_mark_as_read_multiple_times_increments_count
    mutation = <<~GRAPHQL
      mutation {
        markAsRead(slug: "the-great-gatsby") {
          title
          readCount
        }
      }
    GRAPHQL

    # Mark as read 3 times
    result1 = graphql_request(mutation)
    assert_equal 1, result1["data"]["markAsRead"]["readCount"]

    result2 = graphql_request(mutation)
    assert_equal 2, result2["data"]["markAsRead"]["readCount"]

    result3 = graphql_request(mutation)
    assert_equal 3, result3["data"]["markAsRead"]["readCount"]
  end

  def test_mark_as_read_with_invalid_slug_returns_null
    mutation = <<~GRAPHQL
      mutation {
        markAsRead(slug: "nonexistent-book") {
          title
        }
      }
    GRAPHQL

    result = graphql_request(mutation)

    assert_nil result["errors"]
    assert_nil result["data"]["markAsRead"]
  end

  def test_all_books_have_required_fields
    query = <<~GRAPHQL
      query {
        books {
          title
          author
          slug
          publishedYear
        }
      }
    GRAPHQL

    result = graphql_request(query)

    assert_nil result["errors"]
    result["data"]["books"].each do |book|
      assert book["title"]
      assert book["author"]
      assert book["slug"]
      assert book["publishedYear"]
    end
  end

  def test_read_counts_are_independent_per_book
    # Mark different books as read
    graphql_request('mutation { markAsRead(slug: "1984") { readCount } }')
    graphql_request('mutation { markAsRead(slug: "1984") { readCount } }')
    graphql_request('mutation { markAsRead(slug: "moby-dick") { readCount } }')

    query = <<~GRAPHQL
      query {
        books {
          slug
          readCount
        }
      }
    GRAPHQL

    result = graphql_request(query)

    books_by_slug = result["data"]["books"].each_with_object({}) do |book, hash|
      hash[book["slug"]] = book["readCount"]
    end

    assert_equal 2, books_by_slug["1984"]
    assert_equal 1, books_by_slug["moby-dick"]
    assert_equal 0, books_by_slug["pride-and-prejudice"]
  end

  def test_graphql_query_with_missing_query_field_returns_error
    post "/graphql", {}.to_json, {"CONTENT_TYPE" => "application/json"}

    assert last_response.ok?
    result = JSON.parse(last_response.body)
    assert result["errors"]
  end
end
