# == Schema Information
#
# Table name: subject
#
#  id           :bigint           not null, primary key
#  type         :text
#  subject_code :text
#  subject_name :text
#

require "rails_helper"

describe SecondarySubject, type: :model do
  describe "#modern_languages" do
    it "returns the modern language subject" do
      modern_languages = create(:subject, subject_name: "Modern Languages", type: :SecondarySubject).becomes(SecondarySubject)
      expect(SecondarySubject.modern_languages).to eq(modern_languages)
    end
  end
end
