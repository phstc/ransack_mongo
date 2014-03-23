module RansackMongo
  class MongoAdapter
    PREDICATES = %w[eq not_eq cont in gt lt gteq lteq]

    def initialize
      @query = {}
    end

    def to_query
      @query
    end

    def eq_matcher(attr, value)
      @query[attr] = value
    end

    def not_eq_matcher(attr, value)
      @query[attr] = { '$ne' => value }
    end

    def cont_matcher(attr, value)
      @query[attr] = /#{value}/i
    end

    def in_matcher(attr, value)
      @query[attr] = { '$in' => value }
    end

    def gt_matcher(attr, value)
      @query[attr] ||= {}
      @query[attr]['$gt'] = value.to_f
    end

    def lt_matcher(attr, value)
      @query[attr] ||= {}
      @query[attr]['$lt'] = value.to_f
    end

    def gteq_matcher(attr, value)
      @query[attr] ||= {}
      @query[attr]['$gte'] = value.to_f
    end

    def lteq_matcher(attr, value)
      @query[attr] ||= {}
      @query[attr]['$lte'] = value.to_f
    end

    def or_op # or operation
      return unless block_given?

      original_query = @query
      @query = {}

      yield

      original_query['$or'] ||= []
      original_query['$or'].concat @query.map { |attr, value| { attr => value } }

      @query = original_query
    end

    def self.predicates
      PREDICATES
    end
  end
end
