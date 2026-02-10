# frozen_string_literal: true

module Find
  class TrackController < ::TrackController
    include Find::Authentication
  end
end
