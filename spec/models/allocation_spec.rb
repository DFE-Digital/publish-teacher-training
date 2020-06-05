require "rails_helper"

RSpec.describe Allocation do
  describe "validations" do
    before do
      subject.number_of_places = 1
      subject.valid?
    end

    describe "auditing" do
      it { should be_audited.associated_with(:provider) }
    end

    it "requires accredited_body" do
      expect(subject.errors["accredited_body"]).to include("can't be blank")
    end

    it "requires provider" do
      expect(subject.errors["provider"]).to include("can't be blank")
    end

    it "requires the accredited_body to be an accredited_body" do
      subject.accredited_body = create(:provider)
      subject.valid?
      expect(subject.errors["accredited_body"]).to include("must be an accredited body")
    end

    it "requires number_of_places to be a number" do
      subject.number_of_places = "dave"
      subject.valid?
      expect(subject.errors["number_of_places"]).to include("is not a number")
    end

    context "when request type is initial (default)" do
      it "requires number_of_places not to be zero" do
        subject.number_of_places = 0
        subject.valid?
        expect(subject.errors["number_of_places"]).to include("must not be zero")
      end
    end

    context "when request type is repeat" do
      it "doesn't require number_of_places not to be zero" do
        subject.request_type = "repeat"
        subject.number_of_places = 0
        subject.valid?
        expect(subject.errors["number_of_places"]).not_to include("must not be zero")
      end
    end
  end

  describe "number_of_places" do
    context "when request type is initial (default)" do
      context "and number of places is not set" do
        subject { create(:allocation) }

        it "returns an error" do
          expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      context "and number of places is set" do
        subject { create(:allocation, number_of_places: original_number_of_places).number_of_places }

        let(:original_number_of_places) { 10 }

        it "is unchanged" do
          expect(subject).to eq(original_number_of_places)
        end
      end
    end
  end

  describe "#safe_delete" do
    subject { create(:allocation, number_of_places: 1) }

    context "when the recruitment cycle does not match" do
      let(:previous_recruitment_cycle) { create(:recruitment_cycle, :previous) }

      it "returns an error" do
        subject.safe_delete(previous_recruitment_cycle)

        expect(subject.errors[:safe_delete]).to eq(["recruitment cycle does not match"])
      end
    end

    context "when the recruitment cycle matches" do
      let(:current_recruitment_cycle) { find_or_create(:recruitment_cycle) }

      it "deletes the allocation" do
        expect(subject).to receive(:delete)

        subject.safe_delete(current_recruitment_cycle)
      end
    end
  end
end
