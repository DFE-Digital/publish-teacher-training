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
        redirect_to active_support_banners_path, success: "Banner was successfully created."
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
        redirect_to active_support_banners_path, success: "Banner was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

  private

    def banner_params
      params.expect(banner: %i[
        name
        title
        title_heading_level
        success_styling
        heading
        body
        published_at
        expired_at
        display_on_find
        display_on_publish
        display_on_support
      ])
    end
  end
end
