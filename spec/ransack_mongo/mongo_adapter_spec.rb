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

    describe '#start' do
      it 'returns the matcher' do
        subject.start_matcher('object_ref', 'Bruno')

        expect(subject.to_query).to eq("object_ref" => { "$in" => [/^Bruno/] })
      end
    end

    describe '#mstart' do
      it 'returns the matcher' do
        subject.mstart_matcher('name', 'Pablo, Bruno,Dude')

        expect(subject.to_query).to eq("name" => { "$in" => [/^Pablo/i, /^Bruno/i, /^Dude/i] })
      end

      it 'cleans up the input' do
        subject.mstart_matcher('name', ',, , ,Pablo,,,,   ,, , , ,')

        expect(subject.to_query).to eq("name" => { "$in" => [/^Pablo/i] })
      end

      it 'accepts single values' do
        subject.mstart_matcher('name', 'Pablo')

        expect(subject.to_query).to eq("name" => { "$in" => [/^Pablo/i] })
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

    %w[gt lt gteq lteq].each do |m|
      op_name = { 'gteq' => 'gte', 'lteq' => 'lte' }[m] || m

      describe "##{m}_matcher" do
        it 'returns the matcher' do
          subject.send "#{m}_matcher", 'quantity', 1

          expect(subject.to_query).to eq('quantity' => { "$#{op_name}" => 1 })
        end

        it 'accepts time' do
          updated_at = Time.now
          subject.send "#{m}_matcher", 'updated_at', updated_at

          expect(subject.to_query).to eq('updated_at' => { "$#{op_name}" => updated_at })
        end

        it 'accepts time as a string' do
          updated_at = '2014-10-11 14:48:07 -0300'

          subject.send "#{m}_matcher", 'updated_at', updated_at

          expect(subject.to_query).to eq('updated_at' => { "$#{op_name}" => updated_at })
        end

        it 'accepts date' do
          updated_at = Date.new

          subject.send "#{m}_matcher", 'updated_at', updated_at

          expect(subject.to_query).to eq('updated_at' => { "$#{op_name}" => updated_at })
        end
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
