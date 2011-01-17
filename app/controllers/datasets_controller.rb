class DatasetsController < ApplicationController

  def deprecated
    msg = case params[:name]
    when :dataset_by_date
      "The dataset by date [ZIP] resource has been deprecated and is no " \
      "longer available. Datasets are now available at /datasets and are no " \
      "longer SQLite dumps."
    when :current_dataset
      "The current dataset [ZIP] resource has been deprecated and is no " \
      "longer available. Datasets are now available at /datasets and are no " \
      "longer SQLite dumps. You can still download individual datasets at " \
      "/datasets/:id.zip but the format is now CSV and not SQLite."
    end
    render_error :deprecation_notice, msg, 410
  end

  def index
    @query = query(:datasets)

    respond_to do |wants|
      wants.csv { render :text => @query.as_csv }
      wants.tsv { render :text => @query.as_tsv }
      wants.any(:js, :json) { render_json @query.as_json }
    end
  end

  def show
    @query = query(:dataset)

    respond_to do |wants|
      wants.csv { render :text => @query.as_csv }
      wants.tsv { render :text => @query.as_tsv }
      wants.zip { redirect_to @query.as_json[:result][:csv_dump] }
      wants.any(:js, :json) { render_json @query.as_json }
    end
  end

end
