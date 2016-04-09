class BpmTrackerController < ApplicationController
  before_filter :require_admin

  def create
    @tracker = Tracker.new(params[:tracker])
    if @tracker.save
      # workflow copy
      if !params[:copy_workflow_from].blank? && (copy_from = Tracker.find_by_id(params[:copy_workflow_from]))
        @tracker.workflow_rules.copy(copy_from)
      end
      render json: @tracker.to_json
    else
      render json: @tracker.errors.full_messages.to_json
    end
  end
end
