activate :bower
activate :react
activate :syntax

set :markdown_engine, :redcarpet
set :markdown, fenced_code_blocks: true, smartypants: true

activate :blog do |blog|
  blog.publish_future_dated = true
  blog.prefix    = 'news'
  blog.sources   = '{year}-{month}-{day}-{title}'
  blog.permalink = '{title}'
  blog.layout    = 'news_post'
end

activate :directory_indexes

ignore '/docs/template.html.erb'

proxy '/docs/v1/index.html', '/docs/template.html', locals: {
  api: data.v1
}

data.v1.resources.each do |resource|
  proxy "/docs/v1/#{resource.slug}/index.html", '/docs/template.html', locals: {
    api: data.v1,
    api_resource: resource
  }
end

helpers do
  def format_route(route)
    spec = route.gsub(/\{[a-z\_]+\}/) { |part| "<span>#{part}</span>" }
    %|<code class="route-spec"><i>lcboapi.com</i>#{spec}</code>|
  end

  def markdown(source)
    Middleman::Renderers::RedcarpetTemplate.new(
      smartypants: true,
      fenced_code_blocks: true,
      tables: true
    ) { source }.render
  end
end

set :sass_assets_paths, [
  File.expand_path(File.dirname(__FILE__) + '/../manager/app/styles')
]

set :css_dir,    'assets/css'
set :js_dir,     'assets/js'
set :images_dir, 'assets/images'

ready do
  sprockets.append_path File.expand_path(File.dirname(__FILE__) + '/../manager/vendor')
  sprockets.append_path File.dirname(::React::Source.bundled_path_for('react.js'))
end

configure :build do
  # For example, change the Compass output style for deployment
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
end
