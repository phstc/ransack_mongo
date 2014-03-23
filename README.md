# Ransack Mongo

[![Build Status](https://travis-ci.org/phstc/ransack_mongo.svg)](https://travis-ci.org/phstc/ransack_mongo)

Ransack Mongo is based on [Ransack](https://github.com/activerecord-hackery/ransack), but for MongoDB. 

With Ransack Mongo you can convert query params into Mongo queries.

## Installation

Add this line to your application's Gemfile:

    gem 'ransack_mongo'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ransack_mongo

## Usage

```ruby
# GET /customers?q[name_eq]=Pablo&q[middle_name_or_last_name_cont]=Cantero
# params[:q]
# => { name_eq: 'Pablo', middle_name_or_last_name_cont: 'Cantero' }
# query.to_query(params[:q])
# => { name: 'Pablo', '$or' => { middle_name: /Cantero/i, last_name: /Cantero/i } }

# GET /customers
def index
  query = RansackMongo::Query.new
  selector = query.to_query(params[:q])

  # Mongo Ruby Driver
  @customers = db.customers.find(selector)

  # Mongoid
  @customers = Customer.where(selector)
end
```

### Available predicates

* eq
* not_eq
* cont
* in
* gt
* lt
* gteq
* lteq

### OR operator

You can also combine predicates for OR queries.

```ruby
query_param = { name_eq: 'Pablo', middle_name_or_last_name_cont: 'Cantero' }
query.to_query(params[:q])
# => { name: 'Pablo', '$or' => { middle_name: /Cantero/i, last_name: /Cantero/i } }
```

## Contributing

1. Fork it ( https://github.com/phstc/ransack_mongo/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
