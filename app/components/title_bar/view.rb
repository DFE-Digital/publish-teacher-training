# frozen_string_literal: true

module TitleBar
  class View < ViewComponent::Base
    attr_accessor :title

    def initialize(title:)
      super
      @title = title
    end

    def link
      govuk_link_to t("change_organisation"), root_path, class: "title-bar-link inline"
    end
  end
end
