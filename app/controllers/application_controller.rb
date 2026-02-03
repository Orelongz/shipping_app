class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def current_customer
    @current_customer
  end

  def authenticate_customer!
    token = request.headers["X-Api-Token"]

    unless token.present?
      return render json: { error: "Missing X-Api-Token header" }, status: :unauthorized
    end

    @current_customer = Customer.find_by(api_token: token)

    unless @current_customer
      render json: { error: "Invalid X-Api-Token" }, status: :unauthorized
    end
  end
end
