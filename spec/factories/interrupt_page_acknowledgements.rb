FactoryBot.define do
  factory :interrupt_page_acknowledgement do
    user
    recruitment_cycle
    page { :rollover }
  end
end
