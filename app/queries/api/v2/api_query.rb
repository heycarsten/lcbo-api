class API::V2::APIQuery < Magiq::Query
  def self.has_include_dead
    param :include_dead, type: :bool
    apply do
      scope.where(is_dead: false) unless params[:include_dead]
    end
  end
end
