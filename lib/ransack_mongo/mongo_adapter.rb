module RansackMongo
  class MongoAdapter
    PREDICATES = %w[eq not_eq cont in start mstart gt lt gteq lteq]

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
      value.reject!(&:empty?)
      @query[attr] = { '$in' => value } if value.any?
    end

    def start_matcher(attr, value)
      @query[attr] = { '$in' => [/^#{value}/] }
    end

    def mstart_matcher(attr, value)
      values = value.split(",").map do |current|
        if (current = current.strip).length > 0
          /^#{current}/i
        end
      end.compact

      @query[attr] = { '$in' => values }
    end

    def gt_matcher(attr, value)
      append_sizeable_matcher('$gt', attr, value)
    end

    def lt_matcher(attr, value)
      append_sizeable_matcher('$lt', attr, value)
    end

    def gteq_matcher(attr, value)
      append_sizeable_matcher('$gte', attr, value)
    end

    def lteq_matcher(attr, value)
      append_sizeable_matcher('$lte', attr, value)
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

    private

    def append_sizeable_matcher(m, attr, value)
      @query[attr] ||= {}
      @query[attr][m] = parse_sizeable_value(value)
    end

    def parse_sizeable_value(value)
      case value
      when Date, Time
        value
      else
        Float(value) rescue value
      end
    end
  end
end
