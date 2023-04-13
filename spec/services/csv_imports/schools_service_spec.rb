# frozen_string_literal: true

require 'rails_helper'
module CSVImports
  describe SchoolsService do
    let(:csv_content) do
      <<~CSV
        All Saints Catholic College,139735,Birch Lane,,Dukinfield,,SK16 5AP
        Blessed Thomas Holford Catholic College,106376,Urban Road,,Altrincham,,WA15 8HT
        Halton Lodge Primary School,111229,Grangeway,,Runcorn,,WA7 5LU
        Loreto Grammar School,138464,Dunham Road,,Altrincham,Cheshire,WA14 4AH
        Oasis Academy Oldham,136027,Hollins Road,,Oldham,,OL8 4JZ
        Our Lady of Lourdes Catholic Primary School,106346,Lock Lane,Partington,Manchester,,M31 4PJ
        St Clement's Catholic Primary School,111320,Oxford Road,,Runcorn,Cheshire,WA7 4NX
        St Peter's RC High School,131880,Kirkmanshulme Lane,,Manchester,,M12 4WB
        St Vincent's Catholic Primary School,136087,Orchard Road,,Altrincham,Cheshire,WA15 8EY
      CSV
    end

    let(:provider) { create(:provider) }

    subject { described_class.call(csv_content:, provider:) }

    it 'imported all the sites' do
      expect(subject.size).to be(csv_content.lines.count)
    end

    shared_examples 'attribute imported accross from csv' do |attribute_name, index|
      it "correctly mapped #{attribute_name} to #{index}" do
        expect(subject.map(&attribute_name)).to eql(csv_content.lines.map { |line| line.split(',')[index].blank? ? nil : line.split(',')[index].gsub("\n", '') })
      end
    end

    %i[
      location_name
      urn
      address1
      address2
      address3
      town
      address4
      postcode
    ].each_with_index do |attribute_name, index|
      include_examples 'attribute imported accross from csv', attribute_name, index
    end
  end
end
