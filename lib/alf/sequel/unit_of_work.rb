module Alf
  module Sequel
    module UnitOfWork

    end # module UnitOfWork
  end # module Sequel
end # module Alf
require_relative 'unit_of_work/atomic'
require_relative 'unit_of_work/insert'
require_relative 'unit_of_work/delete'
require_relative 'unit_of_work/update'
