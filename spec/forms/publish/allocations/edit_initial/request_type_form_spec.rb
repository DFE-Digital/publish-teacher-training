require "rails_helper"

module Publish
  module Allocations
    module EditInitial
      describe RequestTypeForm do
        context "when request_type is missing" do
          it "returns an error" do
            subject.valid?
            expect(subject.errors[:request_type]).to be_present
          end
        end

        context "when request_type is present" do
          subject do
            described_class.new(request_type: AllocationsView::RequestType::INITIAL)
          end

          it "is valid" do
            expect(subject.valid?).to be(true)
          end
        end
      end
    end
  end
end
