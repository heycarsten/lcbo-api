class API::V2::Responder < ActionController::Responder
  def json_resource_errors
    errs = []

    resource.errors.each do |field, messages|
      messages.each do |msg|
        errs << { path: field, title: msg, code: 'invalid' }
      end
    end

    render json: { errors: errs }, status: 422
  end
end
