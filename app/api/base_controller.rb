module Api
  class BaseController < ApplicationController
    before_action :set_organization
    def set_organization
      params[:organization_id] = 2
    end
  end
end
