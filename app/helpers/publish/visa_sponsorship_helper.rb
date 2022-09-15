module Publish
  module VisaSponsorshipHelper
    def funding_type_updated?
      params[:funding_type_updated] == "true"
    end
  end
end
