require 'spec_helper'

module RansackMongo
  describe Query do
    context 'when FooAdapter' do
      class FooAdapter
        PREDICATES = %w[foo]

        def initialize
          @query = {}
        end

        def to_query
          @query
        end

        def sanitize(unsanitized)
          unsanitized
        end

        def self.predicates
          PREDICATES
        end
      end

      describe '#to_query' do
        context 'when not implement matcher' do
          it 'raises proper exception' do
            params = { 'name_foo' => 'Pablo' }
            expect {
              described_class.new(FooAdapter).to_query(params)
            }.to raise_error(MatcherNotFound, 'The matcher foo `foo_matcher` was not found in the RansackMongo::FooAdapter. Check `RansackMongo::FooAdapter.predicates`')
          end
        end
      end
    end

    context 'when MongoAdapter' do
      describe '#to_query' do
        it 'returns the query' do
          params = { 'name_eq' => 'Pablo', 'fullname_cont' => 'Cantero' }

          expect(described_class.new.to_query(params)).to eq('name' => 'Pablo', 'fullname' => /Cantero/i)
        end

        context 'when or' do
          it 'returns the query' do
            params = { 'name_or_fullname_eq' => 'Pablo' }

            expect(described_class.new.to_query(params)).to eq('$or' => [{ 'name' => 'Pablo' }, { 'fullname' => 'Pablo' }])
          end

          it 'preserves other criterias' do
            params = { 'name_or_fullname_eq' => 'Pablo', 'country_eq' => 'Brazil' }

            expect(described_class.new.to_query(params)).to eq('$or' => [{ 'name' => 'Pablo' }, { 'fullname' => 'Pablo' }], 'country' => 'Brazil')
          end
        end
      end
    end
  end
end
