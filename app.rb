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
  content_type :html
  <<~HTML
            <!DOCTYPE html>
            <html>
              <head>
                <meta charset="UTF-8">
                <title>graphql-docs Demo - Automatic GraphQL Documentation</title>
                <style>
                  body {
                    margin: 0;
                    padding: 0;
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    line-height: 1.6;
                    color: #333;
                  }
                  .hero {
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    color: white;
                    padding: 60px 20px;
                    text-align: center;
                  }
                  .hero h1 {
                    margin: 0 0 10px 0;
                    font-size: 3em;
                    font-weight: 700;
                  }
                  .hero .tagline {
                    font-size: 1.3em;
                    margin: 10px 0 30px 0;
                    opacity: 0.95;
                  }
                  .hero .cta {
                    display: inline-block;
                    background: white;
                    color: #667eea;
                    padding: 12px 30px;
                    margin: 10px;
                    text-decoration: none;
                    border-radius: 6px;
                    font-weight: 600;
                    transition: transform 0.2s;
                  }
                  .hero .cta:hover {
                    transform: translateY(-2px);
                  }
                  .hero .cta.secondary {
                    background: transparent;
                    color: white;
                    border: 2px solid white;
                  }
                  .container {
                    max-width: 1200px;
                    margin: 0 auto;
                    padding: 20px;
                  }
                  .feature-grid {
                    display: grid;
                    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
                    gap: 20px;
                    margin: 40px 0;
                  }
                  .feature {
                    padding: 20px;
                    background: #f9f9f9;
                    border-radius: 8px;
                    border-left: 4px solid #667eea;
                  }
                  .feature h3 {
                    margin-top: 0;
                    color: #667eea;
                  }
                  .section {
                    margin: 40px 0;
                    padding: 30px;
                    background: white;
                    border-radius: 8px;
                    border: 1px solid #e0e0e0;
                  }
                  .section h2 {
                    margin-top: 0;
                    color: #333;
                    border-bottom: 2px solid #667eea;
                    padding-bottom: 10px;
                  }
                  .quick-start {
                    background: #f5f7fa;
                    padding: 20px;
                    border-radius: 6px;
                    margin: 20px 0;
                  }
                  .quick-start h3 {
                    margin-top: 0;
                    color: #667eea;
                  }
                  .quick-start code {
                    display: block;
                    background: #1e1e1e;
                    color: #d4d4d4;
                    padding: 15px;
                    border-radius: 4px;
                    overflow-x: auto;
                    margin: 10px 0;
                    font-family: 'Courier New', monospace;
                    font-size: 14px;
                  }
                  .quick-start ol {
                    margin: 10px 0;
                    padding-left: 20px;
                  }
                  .quick-start li {
                    margin: 8px 0;
                  }
                  .integration-badge {
                    display: inline-block;
                    background: #667eea;
                    color: white;
                    padding: 4px 12px;
                    border-radius: 12px;
                    font-size: 0.9em;
                    margin: 5px 5px 5px 0;
                  }
                  textarea {
                    width: 100%;
                    min-height: 150px;
                    font-family: 'Courier New', monospace;
                    font-size: 14px;
                    padding: 10px;
                    border: 1px solid #ccc;
                    border-radius: 4px;
                    box-sizing: border-box;
                  }
                  button {
                    background: #667eea;
                    color: white;
                    border: none;
                    padding: 12px 24px;
                    font-size: 16px;
                    border-radius: 4px;
                    cursor: pointer;
                    margin-top: 10px;
                    font-weight: 600;
                    transition: background 0.2s;
                  }
                  button:hover {
                    background: #5568d3;
                  }
                  pre {
                    background: #1e1e1e;
                    color: #d4d4d4;
                    padding: 15px;
                    border-radius: 4px;
                    overflow-x: auto;
                  }
                  .examples {
                    margin-top: 20px;
                  }
                  .example {
                    margin: 10px 0;
                    padding: 15px;
                    background: white;
                    border: 1px solid #e0e0e0;
                    border-radius: 6px;
                  }
                  .example-title {
                    font-weight: bold;
                    margin-bottom: 8px;
                    color: #667eea;
                  }
                  .example-query {
                    background: #f5f5f5;
                    padding: 10px;
                    border-radius: 4px;
                    font-family: 'Courier New', monospace;
                    font-size: 13px;
                    cursor: pointer;
                    border: 1px solid #ddd;
                  }
                  .example-query:hover {
                    background: #e8e8e8;
                    border-color: #667eea;
                  }
                  .links {
                    text-align: center;
                    margin: 40px 0;
                    padding: 30px;
                    background: #f9f9f9;
                    border-radius: 8px;
                  }
                  .links a {
                    display: inline-block;
                    margin: 10px 15px;
                    color: #667eea;
                    text-decoration: none;
                    font-weight: 600;
                  }
                  .links a:hover {
                    text-decoration: underline;
                  }
                  footer {
                    text-align: center;
                    padding: 30px;
                    background: #f5f5f5;
                    margin-top: 60px;
                    color: #666;
                  }
                </style>
              </head>
              <body>
                <div class="hero">
                  <h1>graphql-docs</h1>
                  <div class="tagline">Automatic, beautiful documentation for your GraphQL APIs</div>
                  <a href="https://rubygems.org/gems/graphql-docs" class="cta" target="_blank">View on RubyGems</a>
                  <a href="https://github.com/brettchalupa/graphql-docs" class="cta secondary" target="_blank">View on GitHub</a>
                  <a href="/docs/" class="cta">View Generated Docs</a>
                </div>
    
                <div class="container">
                  <div class="section">
                    <h2>What is graphql-docs?</h2>
                    <p><strong>graphql-docs</strong> is a Ruby gem that automatically generates beautiful, static HTML documentation from your GraphQL schema. No manual documentation writing required!</p>
                    <p>It creates comprehensive, searchable documentation for all your types, queries, mutations, and fields - making it easy for developers to understand and use your GraphQL API.</p>
    
                    <div class="feature-grid">
                      <div class="feature">
                        <h3>🚀 Automatic Generation</h3>
                        <p>Generate complete API documentation from your GraphQL schema with a single command</p>
                      </div>
                      <div class="feature">
                        <h3>🎨 Beautiful Design</h3>
                        <p>Clean, professional documentation with syntax highlighting and responsive layout</p>
                      </div>
                      <div class="feature">
                        <h3>🔍 Searchable</h3>
                        <p>Find types, fields, and operations quickly with built-in search functionality</p>
                      </div>
                      <div class="feature">
                        <h3>📦 Static HTML</h3>
                        <p>Deploy anywhere - GitHub Pages, S3, CDN, or serve from your app</p>
                      </div>
                      <div class="feature">
                        <h3>⚙️ Customizable</h3>
                        <p>Custom templates, landing pages, and styling options</p>
                      </div>
                      <div class="feature">
                        <h3>🔗 Complete Coverage</h3>
                        <p>Documents all types: objects, queries, mutations, scalars, enums, interfaces</p>
                      </div>
                    </div>
                  </div>
    
                  <div class="quick-start">
                    <h3>Quick Start</h3>
                    <ol>
                      <li><strong>Add the gem to your Gemfile:</strong></li>
                    </ol>
                    <code>gem "graphql-docs", "~> 5.0"</code>
    
                    <ol start="2">
                      <li><strong>Create a Rake task:</strong></li>
                    </ol>
                    <code>require "graphql-docs"
    
    GraphQLDocs.build(
      schema: YourSchema,
      output_dir: "./docs",
      delete_output: true,
      base_url: "/docs"
    )</code>
    
                    <ol start="3">
                      <li><strong>Generate documentation:</strong></li>
                    </ol>
                    <code>bundle exec rake docs</code>
    
                    <p style="margin-top: 20px;"><strong>That's it!</strong> You now have comprehensive, searchable documentation for your entire GraphQL API.</p>
                  </div>
    
                  <div class="section">
                    <h2>This Demo Project</h2>
                    <p>This is a <strong>complete working example</strong> showing how to integrate graphql-docs into a Ruby GraphQL application. It includes:</p>
                    <ul>
                      <li>A Books API built with <strong>graphql-ruby</strong> and <strong>Sinatra</strong></li>
                      <li>Full graphql-docs integration (see <code>Rakefile:40-54</code>)</li>
                      <li>Generated documentation served at <a href="/docs/">/docs/</a></li>
                      <li>Tests, linting, and CI/CD setup</li>
                      <li>Best practices for schema design and documentation</li>
                    </ul>
    
                    <div style="margin-top: 20px;">
                      <span class="integration-badge">Ruby API</span>
                      <span class="integration-badge">CLI Support</span>
                      <span class="integration-badge">GitHub Actions</span>
                      <span class="integration-badge">Production Ready</span>
                    </div>
                  </div>
    
                  <div class="section">
                    <h2>Try the API</h2>
                    <p>This demo provides a GraphQL API for classic books. Try out some queries below to see the API in action, then check out the <a href="/docs/">generated documentation</a> to see how graphql-docs documents it.</p>
    
                    <textarea id="query" placeholder="Enter your GraphQL query here...">query {
          books {
            title
            author
            slug
            readCount
          }
        }</textarea>
                    <button onclick="executeQuery()">Execute Query</button>
                  </div>
    
                  <div class="section">
                    <h2>Response</h2>
                    <pre id="result">Results will appear here...</pre>
                  </div>
    
                  <div class="examples">
                    <h2>Example Queries</h2>
    
                    <div class="example">
                      <div class="example-title">Get All Books</div>
                      <div class="example-query" onclick="loadExample(this)">query {
          books {
            title
            author
            slug
            readCount
          }
        }</div>
                    </div>
    
                    <div class="example">
                      <div class="example-title">Get Book by Slug</div>
                      <div class="example-query" onclick="loadExample(this)">query {
          book(slug: "pride-and-prejudice") {
            title
            author
            publishedYear
            description
            genre
            pages
            readCount
          }
        }</div>
                    </div>
    
                    <div class="example">
                      <div class="example-title">Mark Book as Read (Mutation)</div>
                      <div class="example-query" onclick="loadExample(this)">mutation {
          markAsRead(slug: "1984") {
            title
            author
            readCount
          }
        }</div>
                    </div>
                  </div>
    
                  <div class="links">
                    <h2>Learn More</h2>
                    <a href="https://rubygems.org/gems/graphql-docs" target="_blank">RubyGems</a>
                    <a href="https://github.com/brettchalupa/graphql-docs" target="_blank">GitHub Repository</a>
                    <a href="/docs/">View Generated Docs</a>
                    <a href="https://github.com/brettchalupa/graphql-docs-demo" target="_blank">Demo Source Code</a>
                  </div>
                </div>
    
                <footer>
                  <p>This is a demonstration project for the <a href="https://github.com/brettchalupa/graphql-docs">graphql-docs</a> gem.</p>
                  <p>Using graphql-docs from <strong>GitHub main branch</strong> to showcase the latest features.</p>
                </footer>
    
                <script>
                  function loadExample(element) {
                    document.getElementById('query').value = element.textContent.trim();
                  }
    
                  async function executeQuery() {
                    const query = document.getElementById('query').value;
                    const resultEl = document.getElementById('result');
    
                    resultEl.textContent = 'Loading...';
    
                    try {
                      const response = await fetch('/graphql', {
                        method: 'POST',
                        headers: {
                          'Content-Type': 'application/json',
                        },
                        body: JSON.stringify({ query })
                      });
    
                      const result = await response.json();
                      resultEl.textContent = JSON.stringify(result, null, 2);
                    } catch (error) {
                      resultEl.textContent = 'Error: ' + error.message;
                    }
                  }
                </script>
              </body>
            </html>
  HTML
end
