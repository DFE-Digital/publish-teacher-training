# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Courses::PublishService do
  subject { described_class.new(course:, user:) }

  let(:uuid) { 'b39fe8fe-7cc5-42b8-a06f-d4461b7eb84e' }
  let(:course) { create(:course, :publishable, uuid:) }
  let(:user) { create(:user, :admin) }

  describe 'publishable' do
    it 'gets published' do
      subject.call
      expect(course.reload).to be_published
    end

    it 'returns the course' do
      return_value = subject.call
      expect(course.reload).to eq(return_value)
    end
  end

  describe 'course is unpublishable' do
    let(:course) { create(:course, uuid:) }

    it 'returns false' do
      expect(subject.call).to be(false)
    end
  end

  describe 'when the course is discarded' do
    let(:course) { create(:course, :publishable, uuid:, discarded_at: 1.minute.ago) }

    it 'the course is undiscarded and published' do
      allow(Course).to receive(:find_by).with({ uuid: uuid }).and_return(course)
      subject.call
      expect(course.reload).to be_published
      expect(course.reload).to be_undiscarded
    end
  end

  describe 'publishing the course fails' do
    it 'the course is unpublished' do
      allow(Course).to receive(:find_by).with({ uuid: uuid }).and_return(course)
      allow(course).to receive(:publish_sites).and_raise(AASM::UnknownStateMachineError)
      subject.call
    rescue AASM::UnknownStateMachineError
      expect(course.reload).not_to be_published
    end
  end
end
