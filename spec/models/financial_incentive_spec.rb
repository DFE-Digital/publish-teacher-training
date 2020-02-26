# == Schema Information
#
# Table name: financial_incentive
#
#  bursary_amount                                 :string
#  created_at                                     :datetime         not null
#  early_career_payments                          :string
#  id                                             :bigint           not null, primary key
#  scholarship                                    :string
#  subject_id                                     :bigint           not null
#  subject_knowledge_enhancement_course_available :boolean          default("false"), not null
#  updated_at                                     :datetime         not null
#
# Indexes
#
#  index_financial_incentive_on_subject_id  (subject_id)
#

require "rails_helper"

describe FinancialIncentive, type: :model do
  describe "associations" do
    it { should belong_to(:subject) }
  end
end
