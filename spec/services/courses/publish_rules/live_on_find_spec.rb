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

  describe ".applies?" do
    context "with a published course in the current cycle" do
      it "applies when the course is running" do
        expect(applies?(running_course)).to be(true)
      end

      it "applies when the course has no schools but support allowed it to publish without them" do
        course = create(:course, :published, publish_without_schools_allowed: true)

        expect(applies?(course)).to be(true)
      end

      it "does not apply when the course is neither running nor exempt" do
        course = create(:course, :published, publish_without_schools_allowed: false)

        expect(applies?(course)).to be(false)
      end
    end

    context "with a published, running course in the next cycle" do
      it "does not apply, because Find only serves the current cycle" do
        provider = create(:provider, recruitment_cycle: create(:recruitment_cycle, :next))

        expect(applies?(running_course(provider:))).to be(false)
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
      "a published, running course" => -> { running_course(provider:) },
      "a published course exempt from needing schools" => -> { create(:course, :published, provider:, publish_without_schools_allowed: true) },
      "a published course that is not running" => -> { create(:course, :published, provider:) },
      "a draft course" => -> { running_course(provider:, enrichments: enrichment(:initial_draft)) },
      "a withdrawn course" => -> { running_course(provider:, enrichments: enrichment(:withdrawn)) },
      "a rolled over course" => -> { running_course(provider:, enrichments: enrichment(:rolled_over)) },
      "a course with no enrichment" => -> { running_course(provider:, enrichments: []) },
    }.each do |description, setup|
      context "with #{description}" do
        let(:provider) { create(:provider) }

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
