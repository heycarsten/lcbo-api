###
# Compass
###

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
page '/', layout: :homepage

# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

ignore '/docs/template.html.erb'

data.endpoints.each do |doc|
  proxy "/docs/#{doc[:slug]}/index.html", '/docs/template.html', locals: { doc: doc }
end

data.documents.each do |doc|
  proxy "/docs/#{doc[:slug]}/index.html", '/docs/template.html', locals: { doc: doc }
end

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Methods defined in the helpers block are available in templates
helpers do
  def format_route(route)
    spec = route.gsub(/:[a-z\_]+/) { |part| "<span>#{part}</span>" }
    %|<code class="route-spec">#{spec}</code>|
  end

  def markdown(source)
    Tilt::KramdownTemplate.new { source }.render
  end
end

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

# Build-specific configuration
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
