class HealthController < ApplicationController
  skip_before_action :verify_authenticity_token

  def show
    # Check database connectivity
    ActiveRecord::Base.connection.execute("SELECT 1")

    render json: {
      status: "ok",
      database: "connected",
      timestamp: Time.current.iso8601
    }, status: :ok
  rescue => e
    render json: {
      status: "error",
      error: e.message,
      database: "disconnected",
      timestamp: Time.current.iso8601
    }, status: :service_unavailable
  end
end
