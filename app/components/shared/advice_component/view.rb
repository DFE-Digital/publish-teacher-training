# frozen_string_literal: true

module Shared
  module AdviceComponent
    class View < ViewComponent::Base
      include ::ViewHelper

      attr_reader :title

      def initialize(title:, show_caption: true)
        super
        @title = title
        @show_caption = show_caption
      end

      def show_caption?
        @show_caption.present?
      end
    end
  end
end
