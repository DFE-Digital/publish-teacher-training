module Support
  class BannersController < ApplicationController
    def index
      scopes = {
        draft: Banner.drafts.drafts_order,
        active: Banner.active.active_order,
        scheduled: Banner.scheduled.scheduled_order,
        expired: Banner.expired.expired_order,
      }
      @scope_status = params[:status]&.to_sym || :draft
      @banners = scopes.fetch(@scope_status, Banner.drafts)
    end

    def show
      @banner = Banner.find(params[:id])
    end

    def new
      @banner = Banner.new
    end

    def create
      @banner = Banner.new(banner_params)
      if @banner.save
        redirect_to banner_status_path(@banner), flash: { success: t("support.flash.created", resource: Banner.name) }
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @banner = Banner.find(params[:id])
    end

    def update
      @banner = Banner.find(params[:id])
      if @banner.update(banner_params)
        redirect_to banner_status_path(@banner), flash: { success: t("support.flash.updated", resource: Banner.name) }
      else
        render :edit, status: :unprocessable_entity
      end
    end

  private

    def banner_status_path(banner)
      {
        draft: drafts_support_banners_path,
        active: active_support_banners_path,
        scheduled: scheduled_support_banners_path,
        expired: expired_support_banners_path,
      }.fetch(banner.status, active_support_banners_path)
    end

    def banner_params
      params.expect(banner: %i[
        body
        display_on_find
        display_on_publish
        display_on_support
        expired_at
        heading
        name
        published_at
        success_styling
        title
        title_heading_level
      ])
    end
  end
end
