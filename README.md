# Alf::Sequel

[![Build Status](https://secure.travis-ci.org/alf-tool/alf-sequel.png)](http://travis-ci.org/alf-tool/alf-sequel)
[![Dependency Status](https://gemnasium.com/alf-tool/alf-sequel.png)](https://gemnasium.com/alf-tool/alf-sequel)

A DBMS adapter for Alf built atop [Sequel](http://sequel.rubyforge.org/).

## Links

* http://github.com/alf-tool/alf
* http://github.com/alf-tool/alf-sql
* http://github.com/alf-tool/alf-sequel

## Synopsis

Extends [alf-sql](https://github.com/alf-tool/alf-sql#synopsis) in such a way
that most existing SQL databases can be used with Alf thanks to the awesome
[Sequel](http://sequel.rubyforge.org/) library.

## Example

```ruby
require 'alf-sequel'

Alf.connect("sap.db") do |conn|

  # Send a query and puts the result
  # (See Alf main docs for smarter ways of using query results)
  relation = conn.query{
    restrict(suppliers, city: 'London')
  }

  puts relation
  # => +------+-------+---------+--------+
  #    | :sid | :name | :status | :city  |
  #    +------+-------+---------+--------+
  #    | S1   | Smith |      20 | London |
  #    | S4   | Clark |      20 | London |
  #    +------+-------+---------+--------+

  # alf-sequel overrides `Operand#to_sql` in such a way that the resulting
  # SQL code is handled by Sequel itself and thus valid for the DBMS
  # considered
  sql = conn.parse{
    restrict(suppliers, city: 'London')
  }.to_sql

  puts sql
  # => SELECT `t1`.`sid`, `t1`.`name`, `t1`.`status`, `t1`.`city`
  #      FROM `suppliers` AS 't1'
  #     WHERE (`t1`.`city` = 'London')
end
```
