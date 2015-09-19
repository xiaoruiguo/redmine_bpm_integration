class BpmController < ApplicationController
  unloadable

  before_filter :authorize_global

  def handle_sucess(msg_code)
    redirect_to :back, notice: l(msg_code)
  end

  def handle_error(msg_code)
    logger.error response.code
    logger.error response.body
    redirect_to :back, alert: l(msg_code)
  end

end
