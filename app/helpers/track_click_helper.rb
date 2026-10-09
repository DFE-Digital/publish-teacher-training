# frozen_string_literal: true

module TrackClickHelper
  def tracked_link_to(text, url:, utm_content: nil, **)
    govuk_link_to(text, find_track_click_path({ url:, utm_content: }.compact), rel: "nofollow", **)
  end
end
