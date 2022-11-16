require "rails_helper"

module FindInterface
  describe DeadlineBannerComponent, type: :component do
    context "when it is mid cycle" do
      it "does not render" do
        Timecop.travel(CycleTimetable.first_deadline_banner - 1.hour) do
          result = render_inline(described_class.new(flash_empty: true))

          expect(result.text).to be_blank
        end
      end
    end

    context "when it is after the first_deadline_banner and before the apply_1_deadline" do
      it "renders the banner with information about apply_1 and apply_2 deadlines" do
        Timecop.travel(CycleTimetable.first_deadline_banner + 1.hour) do
          result = render_inline(described_class.new(flash_empty: true))

          expect(result.text).to include("Courses can fill up at any time, so you should apply as soon as you can.")
          expect(result.text).not_to include("You can continue to view and apply for courses until 6pm on #{CycleTimetable.apply_2_deadline.strftime('%e %B %Y')}")
          expect(result.text).not_to include("as there’s no guarantee that the courses currently shown on this website will be on offer next year.")
        end
      end
    end

    context "when it is after the apply_1_deadline and before the apply_2_deadline" do
      it "renders the banner with information about apply_1 and apply_2 deadlines" do
        Timecop.travel(CycleTimetable.apply_1_deadline + 1.hour) do
          result = render_inline(described_class.new(flash_empty: true))

          expect(result.text).to include("If your application did not lead to a place and you’re applying again")
          expect(result.text).not_to include("Courses can fill up at any time, so you should apply as soon as you can.")
          expect(result.text).not_to include("as there’s no guarantee that the courses currently shown on this website will be on offer next year.")
        end
      end
    end

    context "when it is after the apply_2_deadline and before the find_closes" do
      it "renders the banner with information about apply_1 and apply_2 deadlines" do
        Timecop.travel(CycleTimetable.apply_2_deadline + 1.hour) do
          result = render_inline(described_class.new(flash_empty: true))

          expect(result.text).to include("Courses starting in the #{CycleTimetable.cycle_year_range} academic year are closed")
          expect(result.text).not_to include("Courses can fill up at any time, so you should apply as soon as you can.")
          expect(result.text).not_to include("If your application did not lead to a place and you’re applying again, apply no later than 6pm on #{CycleTimetable.apply_2_deadline.strftime('%e %B %Y')}.")
        end
      end
    end

    context "when find is down" do
      it "does not render" do
        Timecop.travel(CycleTimetable.find_closes + 1.hour) do
          result = render_inline(described_class.new(flash_empty: true))

          expect(result.text).to be_blank
        end
      end
    end
  end
end
