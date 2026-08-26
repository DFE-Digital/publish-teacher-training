module Support
  class BannersController < ApplicationController
    before_action :set_banner, only: %i[show edit update delete destroy]
    before_action :reject_expired, only: %i[edit update]
    before_action :reject_published, only: %i[delete destroy]

    def index
      scopes = {
        scheduled: Banner.scheduled.scheduled_order,
        active: Banner.active.active_order,
        expired: Banner.expired.expired_order,
      }
      @scope_status = params[:status]&.to_sym || :active
      @banners = scopes.fetch(@scope_status, scopes.fetch(:active))
    end

    def show; end

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

    def edit; end

    def update
      if @banner.update(banner_params)
        redirect_to banner_status_path(@banner), flash: { success: t("support.flash.updated", resource: Banner.name) }
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def delete; end

    def destroy
      @banner.destroy!
      redirect_to scheduled_support_banners_path, flash: { success: t("support.flash.deleted", resource: Banner.name) }
    end

  private

    def set_banner
      @banner = Banner.find(params[:id])
    end

    def reject_expired
      return if @banner.editable?

      redirect_to expired_support_banners_path, flash: { warning: t("support.banners.warnings.expired") }
    end

    def reject_published
      return if @banner.deletable?

      redirect_to banner_status_path(@banner), flash: { warning: t("support.banners.warnings.published") }
    end

    def banner_status_path(banner)
      {
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
        name
        published_at
      ])
    end
  end
end
