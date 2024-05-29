# frozen_string_literal: true

require 'site_prism'

module PageObjects
  class Base < SitePrism::Page
    element :back_link, 'a', text: 'Back'
  end
end
