# frozen_string_literal: true

require "rails_helper"

describe Courses::PublishRules::LiveOnFind do
  # The rule reads the content status from the caller rather than the course so
  # that a course list row can hand over Publish::Courses::Query's computed
  # column instead of paying for Course#content_status per row.
  def applies?(course)
    described_class.applies?(course, content_status: course.content_status)
  end

  # :with_full_time_sites gives the course a findable site status, but also a
  # published enrichment. Anything else has to override `enrichments:`, which is
  # the escape hatch the factory documents.
  def running_course(*traits, **overrides)
    create(:course, :with_full_time_sites, *traits, **overrides)
  end

  def enrichment(*traits)
    [build(:course_enrichment, *traits, course: nil)]
  end

  def provider_in(cycle_trait)
    create(:provider, recruitment_cycle: create(:recruitment_cycle, cycle_trait))
  end

  describe ".applies?" do
    context "with a published course in the current cycle" do
      it "applies when the course is running" do
        expect(applies?(running_course)).to be(true)
      end

      # Find's show action only asks whether the course is published, so it
      # serves a course whose sites are not on UCAS just the same. Publish must
      # not be stricter than Find, or it withholds a link to a page that is
      # there.
      it "applies when no site is published, which Find serves anyway" do
        course = running_course(site_statuses: [build(:site_status, status: :new_status, publish: "N")])

        expect(course.is_running?).to be(false)
        expect(applies?(course)).to be(true)
      end
    end

    context "with a published, running course outside the current cycle" do
      it "does not apply to the next cycle, which Find does not serve" do
        expect(applies?(running_course(provider: provider_in(:next)))).to be(false)
      end

      # Find looks the course up by code under RecruitmentCycle.current, so a
      # link built from an earlier cycle's row resolves to whichever course
      # holds that code today — a different course, silently.
      it "does not apply to a previous cycle, whose code would resolve to another course" do
        expect(applies?(running_course(provider: provider_in(:previous)))).to be(false)
      end
    end

    context "when the course is not published" do
      it "does not apply to a draft course" do
        expect(applies?(running_course(enrichments: enrichment(:initial_draft)))).to be(false)
      end

      it "does not apply to a withdrawn course" do
        expect(applies?(running_course(enrichments: enrichment(:withdrawn)))).to be(false)
      end

      it "does not apply to a rolled over course" do
        expect(applies?(running_course(enrichments: enrichment(:rolled_over)))).to be(false)
      end

      it "does not apply to a course with no enrichment at all" do
        expect(applies?(running_course(enrichments: []))).to be(false)
      end
    end
  end

  # Publish::Courses::Query selects content_status as a SQL column, but
  # Course#content_status is a real method that shadows it and runs the
  # enrichment service instead. Both call sites must reach the same verdict, so
  # this pins the row and the model together.
  describe "agreement between the model and the read-model row" do
    {
      "a published course" => -> { running_course(provider:) },
      "a draft course" => -> { running_course(provider:, enrichments: enrichment(:initial_draft)) },
      "a withdrawn course" => -> { running_course(provider:, enrichments: enrichment(:withdrawn)) },
      "a rolled over course" => -> { running_course(provider:, enrichments: enrichment(:rolled_over)) },
      "a course with no enrichment" => -> { running_course(provider:, enrichments: []) },
      "a published course in the next cycle" => -> { running_course(provider:) },
    }.each do |description, setup|
      context "with #{description}" do
        let(:provider) do
          description.include?("next cycle") ? provider_in(:next) : create(:provider)
        end

        it "agrees with the verdict taken from Course#content_status" do
          course = instance_exec(&setup)
          row = Publish::Courses::Query.call(provider: provider.reload).find { |r| r.id == course.id }

          expect(described_class.applies?(row, content_status: row.read_attribute(:content_status)))
            .to eq(applies?(course))
        end
      end
    end
  end
end
