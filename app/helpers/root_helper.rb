module RootHelper

  def format_route(route)
    spec = route.gsub(/:[a-z\_]+/) { |part| "<span>#{part}</span>" }
    capture_haml do
      haml_tag :code, raw(spec), :class => 'route-spec'
    end
  end

end
