activate :bower

ignore '/docs/template.html.erb'

data.endpoints.each do |doc|
  proxy "/docs/#{doc[:slug]}/index.html", '/docs/template.html', locals: { doc: doc }
end

data.documents.each do |doc|
  proxy "/docs/#{doc[:slug]}/index.html", '/docs/template.html', locals: { doc: doc }
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

Sass.load_paths << File.expand_path(File.dirname(__FILE__) + '/../manager')
puts Sass.load_paths.inspect

set :css_dir,    'assets/css'
set :js_dir,     'assets/js'
set :images_dir, 'assets/images'

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
