module Find
  module Utility
    module AdviceComponent
      class View < ViewComponent::Base
        include ::ViewHelper

        attr_reader :title

        def initialize(title:)
          super
          @title = title
        end
      end
    end
  end
end
