require "rails_helper"

describe FindInterface::Courses::ContactDetailsComponent::View, type: :component do
  context "when the email address is not present" do
    it "does not render the email column" do
      provider = build(:provider, provider_code: "BAT", email: nil)
      course = build(:course, course_code: "FIND", provider:).decorate

      result = render_inline(described_class.new(course))
      expect(result.text).not_to include("Email")
    end
  end

  context "when the email address is present" do
    it "renders the email column and given email address" do
      provider = build(:provider, provider_code: "BAT", email: "foo@msn.com")
      course = build(:course, course_code: "FIND", provider:).decorate

      result = render_inline(described_class.new(course))
      expect(result.text).to include("Email")
      expect(result.text).to include("foo@msn.com")
    end
  end

  context "when the telephone is not present" do
    it "does not render the email column" do
      provider = build(:provider, provider_code: "BAT", telephone: nil)
      course = build(:course, course_code: "FIND", provider:).decorate

      result = render_inline(described_class.new(course))
      expect(result.text).not_to include("Telephone")
    end
  end

  context "when the telephone is present" do
    it "renders the telephone column and given number" do
      provider = build(:provider, provider_code: "BAT", telephone: "0207 123 4567")
      course = build(:course, course_code: "FIND", provider:).decorate

      result = render_inline(described_class.new(course))
      expect(result.text).to include("Telephone")
      expect(result.text).to include("0207 123 4567")
    end
  end

  context "when the website is not present" do
    it "does not render the email column" do
      provider = build(:provider, provider_code: "BAT", website: nil)
      course = build(:course, course_code: "FIND", provider:).decorate

      result = render_inline(described_class.new(course))
      expect(result.text).not_to include("Website")
    end
  end

  context "when the website is present" do
    it "renders the website column and given website" do
      provider = build(:provider, provider_code: "BAT", website: "www.madeupsite.com")
      course = build(:course, course_code: "FIND", provider:).decorate

      result = render_inline(described_class.new(course))
      expect(result.text).to include("Website")
      expect(result.text).to include("www.madeupsite.com")
    end
  end

  context "contact details for London School of Jewish Studies and the course code is X104" do
    it "renders the custom address requested via zendesk" do
      provider = build(:provider, provider_code: "28T")
      course = build(:course, course_code: "X104", provider:).decorate

      result = render_inline(described_class.new(course))

      expect(result.text).to include("LSJS", "44A Albert Road", "London", "NW4 2SJ")
    end
  end
end
