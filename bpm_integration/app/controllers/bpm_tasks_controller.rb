class BpmTasksController < ApplicationController
  unloadable

  def index
    @query
    begin
      @bpm_tasks = Httparty.new.bpm_tasks
    rescue
      @bpm_tasks = nil
      redirect_to :back, alert: l('error_bpm_tasks')
    end
  end
end
