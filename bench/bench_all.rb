require_relative '../spec/spec_helper'

include Helpers

def conn
  @conn ||= Alf::Test::Sap.connect
end

def compiler
  @compiler ||= Alf::Compiler::Default.new
end

def translator
  conn.adapter_connection.translator
end

def strip(x)
  x.strip.gsub(/\s+/, " ").gsub(/\(\s+/, "(").gsub(/\s+\)/, ")")
end

def measure
  t1 = Time.now
  res = yield
  t2 = Time.now
  [res, (t2 - t1)]
end

# ensure creation of the parser and compiler
conn.parse("DUM")
compiler
translator

Alf::Test::Sap.each_query do |query|
  next unless query.sqlizable?

  alf_expr, sql_expr = strip(query.alf), strip(query.sql)

  10.times do
    ast,     parsing     = measure{ conn.parse(query.alf)      }
    cog,     compiling   = measure{ compiler.call(ast)         }
    dataset, translating = measure{ translator.call(cog.sexpr) }
    to_sql,  printing    = measure{ cog.to_sql                 }

    puts Alf::Support.to_ruby_literal({
      category: query.category,
      alf: alf_expr,
      sql: sql_expr,
      parsing: parsing,
      compiling: compiling,
      translating: translating,
      printing: printing,
      total: parsing + compiling + translating + printing
    })
  end
end
