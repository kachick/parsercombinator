# coding: us-ascii
# Copyright (c) 2015 Kenichi Kamiya

require_relative '../lib/parsercombinator'

parser = ParserCombinator.build do |h|
  # sequence(
  #   # choice(token('baz'), integer),
  #   token('baz') | integer | token('daafa'),
  #   token('g').optional,
  #   token('foo'),
  #   rest
  # )
  
    # (token('baz') | integer | token('daafa')) + 
    # token('g').optional + 
    # # token('foo') + 
    # regexp(/\Afoo/) + 
    # rest

  integer = regexp /\A(\d+)/
  operator = regexp /\A[+-]/

  parenthesis = lazy do
    token('(') >> h.expression << token(')')
  end

  atom = integer.map{|s|s.to_i} | parenthesis

  h.expression = (atom + (operator + atom).many).map do |ret|
    ret.flatten
  end

end

p parser.run('1+2-(3+1-(4))')
# p parser.run('foobar')
# p parser.run(DATA.read)


csv = "boo,\"foo,woo\",goo\r\nboo,\"foo\"\"woo\",goo\r\n"
csv_parser = ParserCombinator.build do |h|
  
end

csv_parser.parse csv

__END__
