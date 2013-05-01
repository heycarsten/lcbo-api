class RootController < ApplicationController

  def deprecated
    msg = case params[:name]
    when :dataset_by_date
      "The dataset by date [ZIP] endpoint has been deprecated and is no " \
      "longer available. Datasets are now available at /datasets and are no " \
      "longer SQLite dumps."
    when :current_dataset
      "The current dataset [ZIP] endpoint has been deprecated and is no " \
      "longer available. Datasets are now available at /datasets and are no " \
      "longer SQLite dumps. You can still download individual datasets at " \
      "/datasets/:id.zip but the format is now CSV and not SQLite."
    when :store_history
      "The store history endpoint has been deprecated and is no longer " \
      "available. Historical dataset snapshots are available at /datasets."
    when :inventory_history
      "The inventory history endpoint has been deprecated and is no longer " \
      "available. Historical dataset snapshots are available at /datasets."
    when :product_history
      "The product history endpoint has been deprecated and is no longer " \
      "available. Historical dataset snapshots are available at /datasets."
    end
    render_error :deprecation_notice, msg, 410
  end

  def show
    load_documents
    redirect_to '/docs/about' and return unless params[:slug]
    @document = @documents.find { |doc| doc[:slug] == params[:slug] }
    return http_status(404) unless @document
    render layout: 'document'
  end

  def index
    load_documents
  end

  protected

  def load_documents
    docs_path = (Rails.root + 'db' + 'documents.yml').to_s
    raw_yaml  = File.read(docs_path)
    yaml      = ERB.new(raw_yaml).result
    @sections = YAML.load(yaml)
    @sections.values.each do |section|
      section.each { |doc| doc[:slug] = (doc[:menu] || doc[:title]).to_url }
    end
    @documents = @sections.values.flatten
  end

end
