require "rails_helper"

module Find
  describe SubjectsForm do
    describe "validation" do
      it "is not valid when subject codes are not present" do
        form = described_class.new

        expect(form.valid?).to be(false)
      end

      it "is valid when subject codes are present" do
        form = described_class.new(subject_codes: %w[01 02])

        expect(form.valid?).to be(true)
      end
    end
  end
end
