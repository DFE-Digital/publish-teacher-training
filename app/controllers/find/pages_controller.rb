module Find
  class PagesController < ApplicationController
    skip_before_action :redirect_to_maintenance_page_if_flag_is_active, only: :maintenance
    before_action :redirect_to_homepage_unless_in_maintenance_mode, only: :maintenance

    def accessibility; end

    def privacy; end

    def terms; end

    def maintenance; end

  private

    def redirect_to_homepage_unless_in_maintenance_mode
      redirect_to find_path unless FeatureFlag.active?(:maintenance_mode)
    end
  end
end
