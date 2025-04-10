# frozen_string_literal: true

require "rails_helper"

describe StudySitePlacement do
  it { is_expected.to belong_to(:course) }
  it { is_expected.to belong_to(:site) }

  describe "validations" do
    subject { build(:study_site_placement) }

    context "when site is a school" do
      before { allow(subject.site).to receive(:school?).and_return(true) }

      it { is_expected.not_to be_valid }
    end
  end
end
