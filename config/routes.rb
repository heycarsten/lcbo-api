LCBOAPI::Application.routes.draw do
  namespace :admin do
    root :to => 'crawls#index'
    resources :crawls
    resources :crawl_events
  end

  root :to => 'root#index'
  # 
  # match '/stats' => 'crawls#current_stats', :as => :stats
  # 
  # get '/download/current.zip' do
  #   redirect "/download/#{Time.at(DB_TIMESTAMP).strftime('%Y-%m-%d')}.zip"
  # end
  # 
  # get '/download/:filename' do
  #   redirect "http://c0584402.cdn.cloudfiles.rackspacecloud.com/#{params[:filename]}"
  # end
  # 
  # get '/stores/:store_no/products/:product_no/inventory' do
  #   store = DB.stores.get(params[:store_no])
  #   product = DB.products.get(params[:product_no])
  #   @result = DB.store_product_inventories.get(
  #     :product_no => params[:product_no],
  #     :store_no => params[:store_no])
  #   render_json @result, :store => store, :product => product
  # end
  # 
  # get '/stores/:store_no/products/search' do
  #   validate_paging_params!
  #   if 0 == params[:store_no].to_i
  #     halt 404, render_json(nil, :status => 404,
  #       :message => 'No store exists with that store number.')
  #   end
  #   @result = DB.products.paginate(params[:q], {
  #     :store_no => params[:store_no]
  #   }.merge(paging_params))
  #   @suggestion = SS.query(params[:q]) if !params[:q].blank? && @result[:collection].empty? 
  #   @suggestion = nil if @suggestion && DB.products.search(@suggestion).any?
  #   render_json @result[:collection],
  #     :page => pager_meta(@result[:meta]),
  #     :suggestion => titlecase_word(@suggestion)
  # end
  # 
  # get '/products/search' do
  #   validate_paging_params!
  #   @result = DB.products.paginate(params[:q], paging_params)
  #   @suggestion = SS.query(params[:q]) if !params[:q].blank? && @result[:collection].empty?
  #   render_json @result[:collection],
  #     :pager => pager_meta(@result[:meta]),
  #     :suggestion => titlecase_word(@suggestion)
  # end
  # 
  # get '/products/:product_no/inventory' do
  #   @result = DB.store_product_inventories.get_all(
  #     :product_no => params[:product_no])
  #   render_json @result, :product => DB.products.get(params[:product_no])
  # end
  # 
  # get '/stores/near/:lat/:lon/with/:product_no' do
  #   lat, lon = *validate_lat_lon!(params[:lat], params[:lon])
  #   @result = SL.near_with_product(lat, lon, params[:product_no])
  #   render_json @result, :product => DB.products.get(params[:product_no])
  # end
  # 
  # get '/stores/near/geo/with/:product_no' do
  #   begin
  #     geo = get_geo_point(params[:q])
  #     @result = SL.near_with_product(geo[:latitude], geo[:longitude], params[:product_no])
  #     render_json @result, :product => DB.products.get(params[:product_no])
  #   rescue GCoder::Errors::MalformedQueryError, GCoder::Errors::APIGeocodingError
  #     halt 404, render_json([],
  #       :status => 404,
  #       :message => 'The query supplied was not geocodeable.',
  #       :product => DB.products.get(params[:product_no]))
  #   end
  # end
  # 
  # get '/stores/near/:postal_code/with/:product_no' do
  #   begin
  #     postal_code = validate_postal_code!(params[:postal_code])
  #     geo = GEO[postal_code][:point]
  #     @result = SL.near_with_product(geo[:latitude], geo[:longitude], params[:product_no])
  #     render_json @result, :product => DB.products.get(params[:product_no])
  #   rescue GCoder::Errors::MalformedQueryError
  #     halt 404, render_json([], :status => 404,
  #       :message => 'The postal code supplied is not formed correctly.',
  #       :product => DB.products.get(params[:product_no]))
  #   rescue GCoder::Errors::APIGeocodingError
  #     halt 400, render_json([], :status => 400,
  #       :message => 'The postal code supplied was not geocodeable.',
  #       :product => DB.products.get(params[:product_no]))
  #   end
  # end
  # 
  # get '/stores/near/:lat/:lon' do
  #   lat, lon = *validate_lat_lon!(params[:lat], params[:lon])
  #   @result = SL.near(lat, lon)
  #   render_json @result
  # end
  # 
  # get '/stores/near/geo' do
  #   begin
  #     geo = get_geo_point(params[:q])
  #     @result = SL.near(geo[:latitude], geo[:longitude])
  #     render_json @result
  #   rescue GCoder::Errors::MalformedQueryError, GCoder::Errors::APIGeocodingError
  #     halt 404, render_json([], :status => 404,
  #       :message => 'The query supplied was not geocodeable.')
  #   end
  # end
  # 
  # get '/stores/near/:postal_code' do
  #   begin
  #     postal_code = validate_postal_code!(params[:postal_code])
  #     geo = GEO[postal_code][:point]
  #     @result = SL.near(geo[:latitude], geo[:longitude])
  #     render_json @result
  #   rescue GCoder::Errors::MalformedQueryError
  #     halt 404, render_json([], :status => 400,
  #       :message => 'The postal code supplied is not formed correctly.')
  #   rescue GCoder::Errors::APIGeocodingError
  #     halt 400, render_json([], :status => 404,
  #       :message => 'The postal code supplied was not geocodeable.')
  #   end
  # end
  # 
  # get '/stores/search' do
  #   validate_paging_params!
  #   @result = DB.stores.paginate(params[:q], paging_params)
  #   render_json @result[:collection], :pager => pager_meta(@result[:meta])
  # end
  # 
  # get '/stores/nos' do
  #   @result = DB.connection[:stores].select(:store_no).map { |s| s[:store_no] }
  #   render_json @result
  # end
  # 
  # get '/stores/:store_no' do
  #   @result = DB.stores.get(params[:store_no])
  #   if @result
  #     render_json @result
  #   else
  #     halt 404, render_json(nil, :status => 404,
  #       :message => 'No store exists with that store number.')
  #   end
  # end
  # 
  # get '/products/nos' do
  #   @result = DB.connection[:products].select(:product_no).map { |s| s[:product_no] }
  #   render_json @result
  # end
  # 
  # get '/products/:product_no' do
  #   @result = DB.products.get(params[:product_no])
  #   if @result
  #     render_json @result
  #   else
  #     halt 404, render_json(nil, :status => 404,
  #       :message => 'No product exists with that product number.')
  #   end
  # end
  # 
  # get '/docs' do
  #   redirect '/docs/introduction'
  # end
  # 
  # get '/docs/:slug' do
  #   load_documents
  #   if (@document = load_document(params[:slug]))
  #     haml :document, :layout => :doc_layout
  #   else
  #     raise NotFoundError
  #   end
  # end
  # 
  # get '/reflect' do
  #   @service = Reflector.load_file(REFLECTION_FILE)
  #   render_json @service.as_hash
  # end


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get :short
  #       post :toggle
  #     end
  #
  #     collection do
  #       get :sold
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get :recent, :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
