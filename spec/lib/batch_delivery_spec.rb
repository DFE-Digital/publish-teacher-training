# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BatchDelivery do
  let(:relation) { Provider.all }

  describe '#initialize' do
    let(:stagger_over) { 3.hours }
    let(:batch_size) { 50 }

    it 'assigns the provided relation, stagger_over, and batch_size' do
      batch_delivery = described_class.new(relation: relation, stagger_over: stagger_over, batch_size: batch_size)

      expect(batch_delivery.relation).to eq(relation)
      expect(batch_delivery.stagger_over).to eq(stagger_over)
      expect(batch_delivery.batch_size).to eq(batch_size)
    end

    it 'sets default values for stagger_over and batch_size if not provided' do
      batch_delivery = described_class.new(relation: relation)

      expect(batch_delivery.stagger_over).to eq(5.hours)
      expect(batch_delivery.batch_size).to eq(100)
    end
  end

  describe '#each' do
    let(:relation) { Provider.all }
    let(:batch_size) { 2 }
    let(:stagger_over) { 2.hours }
    let(:batch_delivery) { described_class.new(relation: relation, stagger_over: stagger_over, batch_size: batch_size) }

    it 'yields the correct time and batches to the block' do
      create_list(:provider, 6)
      current_time = Time.zone.now
      allow(Time.zone).to receive(:now).and_return(current_time)

      expected_times = [
        current_time,
        current_time + (stagger_over / 2),
        current_time + stagger_over
      ]

      yielded_times = []
      yielded_batches = []

      batch_delivery.each do |time, applications|
        yielded_times << time
        yielded_batches << applications
      end

      expect(yielded_times).to eq(expected_times)
      expect(yielded_batches.map(&:to_a)).to all(be_an(Array))
      expect(yielded_batches.flatten.size).to eq(6)
    end

    it 'handles cases where there is only one batch' do
      create_list(:provider, 1)
      single_batch_relation = Provider.all
      single_batch_delivery = described_class.new(relation: single_batch_relation, batch_size: 10)

      current_time = Time.zone.now
      allow(Time.zone).to receive(:now).and_return(current_time)

      yielded_times = []
      yielded_batches = []

      single_batch_delivery.each do |time, applications|
        yielded_times << time
        yielded_batches << applications
      end

      expect(yielded_times).to eq([current_time])
      expect(yielded_batches.flatten.size).to eq(1)
    end

    it 'does not yield if the relation is empty' do
      Provider.delete_all

      expect { |b| batch_delivery.each(&b) }.not_to yield_control
    end
  end
end
