require 'rails_helper'

RSpec.describe Qualifications, type: :model do
  specs = {
    ["recommendation_for_qts", :not_pgde, :not_fe] => %i[qts],
    ["professional", :not_pgde, :not_fe] => %i[qts pgce],
    ["postgraduate", :not_pgde, :not_fe] => %i[qts pgce],
    ["professional_postgraduate", :not_pgde, :not_fe] => %i[qts pgce],

    ["recommendation_for_qts", :is_pgde, :not_fe] => %i[qts pgde],
    ["professional", :is_pgde, :not_fe] => %i[qts pgde],
    ["postgraduate", :is_pgde, :not_fe] => %i[qts pgde],
    ["professional_postgraduate", :is_pgde, :not_fe] => %i[qts pgde],

    ["recommendation_for_qts", :not_pgde, :is_fe] => [], # nonsensical scenario
    ["professional", :not_pgde, :is_fe] => %i[pgce],
    ["postgraduate", :not_pgde, :is_fe] => %i[pgce],
    ["professional_postgraduate", :not_pgde, :is_fe] => %i[pgce],

    ["recommendation_for_qts", :is_pgde, :is_fe] => %i[pgde],
    ["professional", :is_pgde, :is_fe] => %i[pgde],
    ["postgraduate", :is_pgde, :is_fe] => %i[pgde],
    ["professional_postgraduate", :is_pgde, :is_fe] => %i[pgde],
  }.freeze

  specs.each do |inputs, expected|
    profpost_flag = inputs[0]
    is_pgde = (inputs[1] == :is_pgde)
    is_fe = (inputs[2] == :is_fe)

    context "is #{profpost_flag} and is pgde #{is_pgde} and further education #{is_fe}" do
      subject { Qualifications.new(profpost_flag: profpost_flag, is_pgde: is_pgde, is_fe: is_fe) }

      its(:to_a) { should eq(expected) }
    end
  end
end
