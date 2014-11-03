module RansackMongo
  class Predicate
    def initialize(predicates)
      @predicates = predicates
    end

    def parse(params)
      (params || {}).keys.inject({}) do |query, query_param|
        attr = query_param.to_s
        p, attr = detect_and_strip_from_string(attr)

        if p && attr
          query[p] ||= []
          query[p] << { 'attr' => attr, 'value' => params[query_param] }
        end

        query
      end
    end

    def names_by_decreasing_length
      @predicates.sort { |a, b| b.length <=> a.length }
    end

    def detect_from_string(str)
      names_by_decreasing_length.detect { |p| str.end_with?("_#{p}") }
    end

    def detect_and_strip_from_string(str)
      if p = detect_from_string(str)
        [p, str.sub(/_#{p}$/, '')]
      end
    end
  end
end
