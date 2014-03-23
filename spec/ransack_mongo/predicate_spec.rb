require 'spec_helper'

module RansackMongo
  describe Predicate do
    subject { described_class.new(%w[eq not_eq cont]) }

    describe '#parse' do
      it 'parses predicates' do
        params = { 'name_eq' => 'Pablo', 'name_not_eq' => 'Paul', 'fullname_cont' => 'Cantero' }

        expect(subject.parse(params)).to eq('eq'     => [{ 'attr' => 'name',     'value' => 'Pablo',  }],
                                            'not_eq' => [{ 'attr' => 'name',     'value' => 'Paul',   }],
                                            'cont'   => [{ 'attr' => 'fullname', 'value' => 'Cantero' }])
      end

      it 'ignores unknown predicates' do
        params = { 'name_eq' => 'Pablo', 'name_bbb' => 'Paul' }

        expect(subject.parse(params)).to eq('eq' => [{ 'attr' => 'name',     'value' => 'Pablo',  }])
      end
    end
  end
end
