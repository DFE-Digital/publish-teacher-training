require 'rails_helper'

RSpec.describe Qualifications, type: :model do
  describe 'QTS' do
    context "is recommendation_for_qts and is not pgde and is not further education" do
      subject { Qualifications.new(profpost_flag: "recommendation_for_qts", is_pgde: false, is_fe: false) }

      its(:to_a) { should eq([:qts]) }
    end
  end

  describe 'PGCE with QTS' do
    context "is professional and is not pgde and is not further education" do
      subject { Qualifications.new(profpost_flag: "professional", is_pgde: false, is_fe: false) }

      its(:to_a) { should match_array(%i[qts pgce]) }
    end

    context "is postgraduate and is not pgde and is not further education" do
      subject { Qualifications.new(profpost_flag: "professional", is_pgde: false, is_fe: false) }

      its(:to_a) { should match_array(%i[qts pgce]) }
    end

    context "is professional_postgraduate and is not pgde and is not further education" do
      subject { Qualifications.new(profpost_flag: "professional", is_pgde: false, is_fe: false) }

      its(:to_a) { should match_array(%i[qts pgce]) }
    end
  end

  describe 'PGDE with QTS' do
    context "is recommendation_for_qts and is pgde and is not further education" do
      subject { Qualifications.new(profpost_flag: "recommendation_for_qts", is_pgde: true, is_fe: false) }

      its(:to_a) { should match_array(%i[qts pgde]) }
    end
    context "is professional and is pgde and is not further education" do
      subject { Qualifications.new(profpost_flag: "professional", is_pgde: true, is_fe: false) }

      its(:to_a) { should match_array(%i[qts pgde]) }
    end

    context "is postgraduate and is pgde and is not further education" do
      subject { Qualifications.new(profpost_flag: "professional", is_pgde: true, is_fe: false) }

      its(:to_a) { should match_array(%i[qts pgde]) }
    end

    context "is professional_postgraduate and is pgde and is not further education" do
      subject { Qualifications.new(profpost_flag: "professional", is_pgde: true, is_fe: false) }

      its(:to_a) { should match_array(%i[qts pgde]) }
    end
  end

  describe 'PGCE' do
    context "is recommendation_for_qts and is not pgde and is further education" do
      subject { Qualifications.new(profpost_flag: "recommendation_for_qts", is_pgde: false, is_fe: true) }

      its(:to_a) { should match_array([:pgce]) }
    end

    context "is professional and is not pdge and is further education" do
      subject { Qualifications.new(profpost_flag: "professional", is_pgde: false, is_fe: true) }

      its(:to_a) { should match_array([:pgce]) }
    end

    context "is postgraduate and is not pdge and is further education" do
      subject { Qualifications.new(profpost_flag: "professional", is_pgde: false, is_fe: true) }

      its(:to_a) { should match_array([:pgce]) }
    end

    context "is professional_postgraduate and is not pdge and is further education" do
      subject { Qualifications.new(profpost_flag: "professional", is_pgde: false, is_fe: true) }

      its(:to_a) { should match_array([:pgce]) }
    end
  end

  describe 'PGDE' do
    context "is recommendation_for_qts and is pgde and is further education" do
      subject { Qualifications.new(profpost_flag: "recommendation_for_qts", is_pgde: true, is_fe: true) }

      its(:to_a) { should match_array([:pgde]) }
    end

    context "is professional and is pgde and is further education" do
      subject { Qualifications.new(profpost_flag: "professional", is_pgde: true, is_fe: true) }

      its(:to_a) { should match_array([:pgde]) }
    end

    context "is postgraduate and is pgde and is further education" do
      subject { Qualifications.new(profpost_flag: "professional", is_pgde: true, is_fe: true) }

      its(:to_a) { should match_array([:pgde]) }
    end

    context "is professional_postgraduate and is pgde and is further education" do
      subject { Qualifications.new(profpost_flag: "professional", is_pgde: true, is_fe: true) }

      its(:to_a) { should match_array([:pgde]) }
    end
  end
end
