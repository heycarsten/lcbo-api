class Api::V1::ProductsController < Api::V1::ApiController
  def index
    @query = query(:products)

    respond_to do |format|
      format.csv { render text: @query.as_csv }
      format.tsv { render text: @query.as_tsv }
      format.any(:js, :json) { render_json @query.as_json }
    end
  end

  def show
    @query = query(:product)

    respond_to do |format|
      format.csv { render text: @query.as_csv }
      format.tsv { render text: @query.as_tsv }
      format.any(:js, :json) { render_json @query.as_json }
    end
  end
end
