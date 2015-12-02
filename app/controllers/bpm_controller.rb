class BpmController < ApplicationController
  unloadable

  before_filter :authorize_global

end
