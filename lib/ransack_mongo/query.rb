module RansackMongo
  class MatcherNotFound < StandardError; end

  # https://github.com/activerecord-hackery/ransack/wiki/Basic-Searching
  class Query
    class << self
      def parse(params, db_adapter_class = MongoAdapter)
        parsed_predicates = Predicate.new(db_adapter_class.predicates).parse(params)

        db_adapter = db_adapter_class.new

        parsed_predicates.keys.each do |p|
          parsed_predicates[p].each do |parsed_predicate|
            attr  = parsed_predicate['attr']
            value = parsed_predicate['value']

            begin
              if attr.include? '_or_'
                # attr => name_or_lastname
                or_query(db_adapter, attr, value, p)
              else
                # attr => name
                db_adapter.send("#{p}_matcher", attr, value)
              end
            rescue NoMethodError => e
              raise MatcherNotFound, "The matcher #{p} `#{p}_matcher` was not found in the #{db_adapter_class.name}. Check `#{db_adapter_class}.predicates`"
            end
          end
        end

        db_adapter.to_query
      end

      def parse!(params, db_adapter_class = MongoAdapter)
        if (selector = parse(params)).empty?
          raise MatcherNotFound,  'No matchers found. To allow empty queries use .parse instead'
        end

        selector
      end

      private

      def or_query(db_adapter, attr, value, p)
        db_adapter.or_op do
          attr.split('_or_').each do |or_attr|
            db_adapter.send("#{p}_matcher", or_attr, value)
          end
        end
      end
    end
  end
end
