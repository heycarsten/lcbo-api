class API::V1::InventoriesController < API::V1::APIController
  def index
    @query = query(:inventories)

    respond_to do |format|
      format.csv { render text: @query.as_csv }
      format.tsv { render text: @query.as_tsv }
      format.any(:js, :json) { render_json @query.as_json }
    end
  end

  def show
    @query = query(:inventory)

    respond_to do |format|
      format.csv { render text: @query.as_csv }
      format.tsv { render text: @query.as_tsv }
      format.any(:js, :json) { render_json @query.as_json }
    end
  end
end
