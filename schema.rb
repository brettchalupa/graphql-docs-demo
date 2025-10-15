require "graphql"
require "yaml"

# In-memory storage for read counts
READ_COUNTS = Hash.new(0)

# Book Type
class BookType < GraphQL::Schema::Object
  field :title, String, null: false
  field :author, String, null: false
  field :slug, String, null: false
  field :published_year, Integer, null: false
  field :description, String, null: true
  field :genre, String, null: true
  field :pages, Integer, null: true
  field :read_count, Integer, null: false, description: "Number of times this book has been read"

  def read_count
    READ_COUNTS[object["slug"]]
  end
end

# Query Type
class QueryType < GraphQL::Schema::Object
  # Query to get all books
  field :books, [BookType], null: false, description: "Returns a list of all books"

  def books
    load_books
  end

  # Query to get a book by slug
  field :book, BookType, null: true, description: "Returns a single book by slug" do
    argument :slug, String, required: true
  end

  def book(slug:)
    load_books.find { |book| book["slug"] == slug }
  end

  private

  def load_books
    data = YAML.load_file(File.join(__dir__, "data", "books.yml"))
    data["books"]
  end
end

# Mutation Type
class MutationType < GraphQL::Schema::Object
  field :mark_as_read, BookType, null: true, description: "Mark a book as read and increment its read count" do
    argument :slug, String, required: true
  end

  def mark_as_read(slug:)
    books = load_books
    book = books.find { |b| b["slug"] == slug }

    if book
      READ_COUNTS[slug] += 1
      book
    end
  end

  private

  def load_books
    data = YAML.load_file(File.join(__dir__, "data", "books.yml"))
    data["books"]
  end
end

# Schema
class BooksSchema < GraphQL::Schema
  query QueryType
  mutation MutationType
end
