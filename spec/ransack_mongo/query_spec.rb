require 'spec_helper'

module RansackMongo
  describe Query do
    context 'when FooAdapter' do
      class FooAdapter
        PREDICATES = %w[foo]

        def initialize
          @query = {}
        end

        def parse
          @query
        end

        def self.predicates
          PREDICATES
        end
      end

      describe '.parse' do
        context 'when not implement matcher' do
          it 'raises proper exception' do
            params = { 'name_foo' => 'Pablo' }
            expect {
              described_class.parse(params, FooAdapter)
            }.to raise_error(MatcherNotFound, 'The matcher foo `foo_matcher` was not found in the RansackMongo::FooAdapter. Check `RansackMongo::FooAdapter.predicates`')
          end
        end
      end
    end

    context 'when MongoAdapter' do
      describe '.parse!' do
        it 'raises exception when query evaluates to an empty hash' do
          params = { 'name' => 'Pablo' }
          expect { described_class.parse!(params) }.to raise_error(MatcherNotFound)
        end

        it 'returns the query' do
          params = { 'name_eq' => 'Pablo', 'fullname_cont' => 'Cantero' }

          expect(described_class.parse!(params)).to eq('name' => 'Pablo', 'fullname' => /Cantero/i)
        end
      end

      describe '.parse' do
        it 'returns the query' do
          params = { 'name_eq' => 'Pablo', 'fullname_cont' => 'Cantero' }

          expect(described_class.parse(params)).to eq('name' => 'Pablo', 'fullname' => /Cantero/i)
        end

        context 'when nil query' do
          it 'return an empty query' do
            expect(described_class.parse(nil)).to eq({})
          end
        end

        context 'when or' do
          it 'returns the query' do
            params = { 'name_or_fullname_eq' => 'Pablo' }

            expect(described_class.parse(params)).to eq('$or' => [{ 'name' => 'Pablo' }, { 'fullname' => 'Pablo' }])
          end

          it 'preserves other criterias' do
            params = { 'name_or_fullname_eq' => 'Pablo', 'country_eq' => 'Brazil' }

            expect(described_class.parse(params)).to eq('$or' => [{ 'name' => 'Pablo' }, { 'fullname' => 'Pablo' }], 'country' => 'Brazil')
          end
        end
      end
    end
  end
end
