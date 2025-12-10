require "rails_helper"

RSpec.describe Support::StatusColourHelper, type: :helper do
  describe "#status_colour" do
    it "returns 'blue' for 'pending' status" do
      expect(helper.status_colour("pending")).to eq("blue")
    end

    it "returns 'yellow' for 'submitted' status" do
      expect(helper.status_colour("submitted")).to eq("yellow")
    end

    it "returns 'grey' for 'expired' status" do
      expect(helper.status_colour("expired")).to eq("grey")
    end

    it "returns 'green' for 'closed' status" do
      expect(helper.status_colour("closed")).to eq("green")
    end

    it "returns 'red' for 'rejected' status" do
      expect(helper.status_colour("rejected")).to eq("red")
    end

    it "returns 'grey' for unknown status" do
      expect(helper.status_colour("unknown_status")).to eq("grey")
    end
  end
end
