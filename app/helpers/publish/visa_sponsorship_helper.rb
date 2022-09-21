module Publish
  module VisaSponsorshipHelper
    def funding_type_updated?
      params[:funding_type_updated] == "true"
    end

    def origin_step
      params[:origin_step]
    end
  end
end
