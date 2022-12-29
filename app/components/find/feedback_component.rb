module Find
  class FeedbackComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :path, :controller

    def initialize(path:, controller:)
      super
      @path = path
      @controller = controller
    end
  end
end
