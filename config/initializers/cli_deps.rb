class MissingCLIDependencyError < StandardError; end

def require_cli_dependency(name, pkg_name = name)
  return unless `which #{name}`.strip == ''
  raise MissingCLIDependencyError, "Required dependency '#{name}' is " \
  "missing, to install it run: apt-get install #{pkg_name}"
end

require_cli_dependency 'zip'
