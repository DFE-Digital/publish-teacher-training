class Support::GeolocationCachesController < ApplicationController
  def show
    @count = Rails.cache.fetch("geolocation:querystats:count", expires_in: 3.days) do
      Geolocation::QueryCache.count
    end
    @count_expires_at = Time.zone.at(Rails.cache.send(:read_entry, "geolocation:querystats:count").expires_at)

    @entries = Rails.cache.fetch("geolocation:querystats:keys", expires_in: 3.days) do
      Geolocation::QueryCache.entries
    end
  end

  def update
    result = Geolocation::QueryCache.clear_stats!

    if result
      redirect_to support_geolocation_cache_path, flash: { success: "Geolocation cache stats are refreshed!" }
    else
      flash.now[:warning] = "Something went wrong"
      render :show
    end
  end

  def delete; end

  def destroy
    result = Geolocation::QueryCache.clear! && Geolocation::QueryCache.clear_stats!

    if result
      redirect_to support_geolocation_cache_path, flash: { success: "Cache is cleared" }
    else
      flash.now[:warning] = "Something went wrong"
      render :show
    end
  end
end
