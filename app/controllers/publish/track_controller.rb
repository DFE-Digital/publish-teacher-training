module Publish
  # Class created to make course trackable links to work when previewing
  #
  class TrackController < Find::TrackController
    def track_click_event(utm_content, url)
      # do not track click events
    end
  end
end
