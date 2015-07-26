module Api
  class BaseController < ApplicationController
    before_action :set_organization
    protected
    def set_organization
      params[:organization_id] = 2
    end
  end
end
