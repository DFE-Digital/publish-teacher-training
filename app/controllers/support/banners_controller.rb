module Support
  class BannersController < ApplicationController
    def index
      scopes = {
        draft: Banner.drafts.order(created_at: :desc),
        active: Banner.active.order(published_at: :desc, expired_at: :asc),
        scheduled: Banner.scheduled.order(published_at: :asc),
        expired: Banner.expired.order(expired_at: :desc, published_at: :desc),
      }
      @scope_status = params[:status]&.to_sym || :draft
      @banners = scopes.fetch(@scope_status, Banner.drafts)
    end
  end
end
