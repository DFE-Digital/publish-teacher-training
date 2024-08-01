# frozen_string_literal: true

module ProviderWebsiteRedirect
  extend ActiveSupport::Concern

  def provider_website
    redirect_to provider.decorate.website, allow_other_host: true
  end
end
