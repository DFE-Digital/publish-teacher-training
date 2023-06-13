# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SiteStatus do
  it_behaves_like 'Touch course', :site_status

  describe 'auditing' do
    it { is_expected.to be_audited.associated_with(:course) }
  end

  describe 'associations' do
    subject { build(:site_status) }

    it { is_expected.to belong_to(:site) }
    it { is_expected.to belong_to(:course) }
  end

  describe 'findable?' do
    describe 'if discontinued on UCAS' do
      subject { create(:site_status, :discontinued) }

      it { is_expected.not_to be_findable }
    end

    describe 'if suspended on UCAS' do
      subject { create(:site_status, :suspended) }

      it { is_expected.not_to be_findable }
    end

    describe 'if new on UCAS' do
      subject { create(:site_status, :new_status) }

      it { is_expected.not_to be_findable }
    end

    describe 'if running but not published on UCAS' do
      subject { create(:site_status, :running, :unpublished) }

      it { is_expected.not_to be_findable }
    end

    describe 'if running and published on UCAS' do
      subject { create(:site_status, :running, :published) }

      it { is_expected.to be_findable }
    end
  end

  describe 'findable scope' do
    subject { SiteStatus.findable }

    context 'with a course discontinued on UCAS' do
      it { is_expected.not_to include(create(:site_status, :discontinued)) }
    end

    context 'if suspended on UCAS' do
      it { is_expected.not_to include(create(:site_status, :suspended)) }
    end

    context 'if new on UCAS' do
      it { is_expected.not_to include(create(:site_status, :new_status)) }
    end

    describe 'if running but not published on UCAS' do
      it { is_expected.not_to include(create(:site_status, :running, :unpublished)) }
    end

    describe 'if running and published on UCAS' do
      it { is_expected.to include(create(:site_status, :running, :published)) }
    end
  end

  describe 'status changes' do
    describe 'when suspending a running, published site status' do
      subject { create(:site_status, :running, :published).tap(&:suspend!).reload }

      it { is_expected.to be_status_suspended }
      it { is_expected.to be_unpublished_on_ucas }
    end

    %i[new_status suspended discontinued].each do |status|
      describe "when starting a #{status}, unpublished site status" do
        subject { create(:site_status, status, :unpublished).tap(&:start!).reload }

        it { is_expected.to be_status_running }
        it { is_expected.to be_published_on_ucas }
      end
    end
  end
end
