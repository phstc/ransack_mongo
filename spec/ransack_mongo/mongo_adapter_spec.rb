require 'spec_helper'

module RansackMongo
  describe MongoAdapter do
    describe '#eq_matcher' do
      it 'returns the matcher' do
        subject.eq_matcher('name', 'Pablo')

        expect(subject.to_query).to eq('name' => 'Pablo')
      end
    end

    describe '#not_eq_matcher' do
      it 'returns the matcher' do
        subject.not_eq_matcher('name', 'Pablo')

        expect(subject.to_query).to eq('name' => { '$ne' => 'Pablo' })
      end
    end

    describe '#cont_matcher' do
      it 'returns the matcher' do
        subject.cont_matcher('name', 'Pablo')

        expect(subject.to_query).to eq('name' => /Pablo/i)
      end
    end

    describe '#in_matcher' do
      it 'returns the matcher' do
        subject.in_matcher('name', %w[Pablo Cantero])

        expect(subject.to_query).to eq('name' => { '$in' => %w[Pablo Cantero] })
      end
    end

    context 'when combine gt lt gteq and lteq' do
      it 'returns all matchers' do
        subject.gt_matcher('count', '1')
        subject.lt_matcher('count', '5')

        subject.gteq_matcher('quantity', '10.5')
        subject.lteq_matcher('quantity', '15')

        # all string values must be convert to float `to_f` otherwise mongo will not filter them properly
        expect(subject.to_query).to eq('count'    => { '$gt'  => 1.0,  '$lt'  => 5.0  },
                                       'quantity' => { '$gte' => 10.5, '$lte' => 15.0 })
      end
    end

    describe '#gt_matcher' do
      it 'returns the matcher' do
        subject.gt_matcher('quantity', 1)

        expect(subject.to_query).to eq('quantity' => { '$gt' => 1 })
      end
    end

    describe '#lt_matcher' do
      it 'returns the matcher' do
        subject.lt_matcher('quantity', 1)

        expect(subject.to_query).to eq('quantity' => { '$lt' => 1 })
      end
    end

    describe '#gteq_matcher' do
      it 'returns the matcher' do
        subject.gteq_matcher('quantity', 1)

        expect(subject.to_query).to eq('quantity' => { '$gte' => 1 })
      end
    end

    describe '#lteq_matcher' do
      it 'returns the matcher' do
        subject.lteq_matcher('quantity', 1)

        expect(subject.to_query).to eq('quantity' => { '$lte' => 1 })
      end
    end

    describe '#or_op' do
      it 'returns the or operation' do
        subject.or_op do
          subject.eq_matcher('name',      'Pablo')
          subject.eq_matcher('lastname',  'Pablo')
        end

        expect(subject.to_query).to eq('$or' => [{ 'name' => 'Pablo' }, { 'lastname' => 'Pablo' }])
      end

      it 'preserves other criterias' do
        subject.or_op do
          subject.eq_matcher('name',      'Pablo')
          subject.eq_matcher('lastname',  'Pablo')
        end

        subject.eq_matcher('country',  'Brazil')

        expect(subject.to_query).to eq('$or' => [{ 'name' => 'Pablo' }, { 'lastname' => 'Pablo' }], 'country' => 'Brazil')
      end
    end
  end
end
