class RootController < ApplicationController

  before_filter :load_documents

  def show
    @document = @documents.find { |doc| doc[:slug] == params[:slug] }
    return status(404) unless @document
    render :layout => 'document'
  end

  def index
  end

  protected

  def load_documents
    return if @documents
    docs_path = (Rails.root + 'db' + 'documents.yml').to_s
    raw_yaml  = File.read(docs_path)
    yaml      = ERB.new(raw_yaml).result
    @sections = YAML.load(yaml)
    @sections.values.each do |section|
      section.each { |doc| doc[:slug] = doc[:title].to_url }
    end
    @documents = @sections.values.flatten
  end

end
