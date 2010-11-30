Haml::Template.options[:ugly] = false
Haml::Template.options[:format] = :html5
Haml::Template.options[:attr_wrapper] = '"'

Sass::Plugin.options[:template_location] = (Rails.root + 'app' + 'sass').to_s
Sass::Plugin.options[:css_location] = (Rails.root + 'public' + 'css').to_s
Sass::Plugin.options[:style] = :compressed
