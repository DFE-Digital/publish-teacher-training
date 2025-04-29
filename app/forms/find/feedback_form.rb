module Find
  class FeedbackForm
    include ActiveModel::Model

    attr_accessor :ease_of_use, :experience

    validates :ease_of_use, presence: true
    validates :experience, presence: true, length: { maximum: 1200 }
  end
end
