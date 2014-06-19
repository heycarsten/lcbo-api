docs_path = (Rails.root + 'db' + 'documents.yml').to_s
raw_yaml  = File.read(docs_path)
yaml      = ERB.new(raw_yaml).result
sections = YAML.load(yaml)
sections.values.each do |section|
  section.each { |doc| doc[:slug] = (doc[:menu] || doc[:title]).parameterize }
end
documents = sections.values.flatten

SECTIONS  = sections
DOCUMENTS = documents
