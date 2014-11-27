activate :bower
activate :react
activate :syntax

activate :blog do |blog|
  blog.prefix    = 'news'
  blog.permalink = '{title}'
  blog.sources   = '{year}-{month}-{day}-{title}'
end

set :markdown_engine, :redcarpet
set :markdown, fenced_code_blocks: true, smartypants: true

activate :directory_indexes

page '/news/*', layout: :news_post

ignore '/docs/template.html.erb'

data.v1.endpoints.each do |doc|
  proxy "/docs/v1/#{doc[:slug]}/index.html", '/docs/template.html', locals: { doc: doc }
end

helpers do
  def format_route(route)
    spec = route.gsub(/:[a-z\_]+/) { |part| "<span>#{part}</span>" }
    %|<code class="route-spec">#{spec}</code>|
  end

  def markdown(source)
    Tilt::KramdownTemplate.new { source }.render
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
