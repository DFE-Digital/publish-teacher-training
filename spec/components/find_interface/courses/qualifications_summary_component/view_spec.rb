require "rails_helper"

describe FindInterface::Courses::QualificationsSummaryComponent::View, type: :component do
  context "QTS qualification" do
    it "renders correct text" do
      result = render_inline(described_class.new("QTS"))

      expect(result.text).to include("Qualified teacher status (QTS) allows you to teach in state schools in England")
    end
  end

  context "PGCE with QTS qualification" do
    it "renders correct text" do
      result = render_inline(described_class.new("PGCE with QTS"))

      expect(result.text).to include("A postgraduate certificate in education (PGCE) with qualified teacher status (QTS) will allow you to teach in state schools in England")
    end
  end

  context "PGDE with QTS qualification" do
    it "renders correct text" do
      result = render_inline(described_class.new("PGDE with QTS"))

      expect(result.text).to include("A postgraduate diploma in education (PGDE) with qualified teacher status (QTS) will allow you to teach in state schools in England")
    end
  end

  context "PGCE qualification" do
    it "renders correct text" do
      result = render_inline(described_class.new("PGCE"))

      expect(result.text).to include("A postgraduate certificate in education (PGCE) is an academic qualification in education.")
    end
  end

  context "PGDE qualification" do
    it "renders correct text" do
      result = render_inline(described_class.new("PGDE"))

      expect(result.text).to include("A postgraduate diploma in education (PGDE) is equivalent to a postgraduate certificate in education (PGCE).")
    end
  end
end
