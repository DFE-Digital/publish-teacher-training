# frozen_string_literal: true

module Find
  class ErrorsController < ApplicationController
    include Errorable

    layout "find_layout"
  end
end
