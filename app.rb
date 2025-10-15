require "sinatra"
require "json"
require_relative "schema"

# Configure Sinatra
configure do
  # Disable host authorization in test environment
  if ENV["RACK_ENV"] == "test"
    set :protection, false
  else
    set :protection, except: [:json_csrf]
  end
end

# GraphQL API endpoint
post "/graphql" do
  request.body.rewind
  payload = JSON.parse(request.body.read)

  result = BooksSchema.execute(
    payload["query"],
    variables: payload["variables"] || {},
    context: {},
    operation_name: payload["operationName"]
  )

  content_type :json
  result.to_json
end

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

# GraphQL Playground UI
get "/" do
  erb :index
end
