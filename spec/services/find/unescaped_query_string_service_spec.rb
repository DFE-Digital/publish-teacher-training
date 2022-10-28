require "rails_helper"

module Find
  describe UnescapedQueryStringService do
    context "with C# style parameters" do
      subject { described_class.call(base_path: "/test", parameters: { test: "1,2,3" }) }

      it { is_expected.to eq("/test?test=1,2,3") }
    end

    context "with Rails style parameters" do
      subject { described_class.call(base_path: "/test", parameters: { test: [1, 2, 3] }) }

      it { is_expected.to eq("/test?test%5B%5D=1&test%5B%5D=2&test%5B%5D=3") }
    end
  end
end
