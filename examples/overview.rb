# coding: us-ascii
# Copyright (c) 2015 Kenichi Kamiya

require_relative '../lib/parsercombinator'

parser = ParserCombinator.build do |h|
  # sequence(
  #   # choice(string('baz'), integer),
  #   string('baz') | integer | string('daafa'),
  #   string('g').optional,
  #   string('foo'),
  #   rest
  # )
  
    # (string('baz') | integer | string('daafa')) + 
    # string('g').optional + 
    # # string('foo') + 
    # regexp(/\Afoo/) + 
    # rest

  integer = regexp /\A(\d+)/
  operator = regexp /\A[+-]/

  parenthesis = lazy do
    string('(') >> h.expression << string(')')
  end

  atom = integer.map{|s|s.to_i} | parenthesis

  # h.expression = (atom + (operator + atom).many).map do |ret|
  #   ret.flatten
  # end
  h.expression = sequence(atom, (operator + atom).many)
end

# p parser.parse('1+2-(3+1-(4))')
# p parser.parse('foobar')
# p parser.parse(DATA.read)


csv = "boo,\"foo,woo\",goo\r\nboo,\"foo\"\"woo\",goo\r\n"
csv_parser = ParserCombinator.build do |h|
  lf = string "\x0a"
  cr = string "\x0d"
  crlf = cr >> lf
  dquote = string '"'
  comma = string ','
  textdata = regexp /\A[a-z]+/i
  nonescaped = textdata.many
  escaped = dquote >> (textdata | comma | cr | lf | (dquote >> dquote).try).many << dquote
  field = escaped | nonescaped
  record = field.sepby1 comma
  record.endby1(crlf)
end

p csv_parser.parse(csv)

# parser = ParserCombinator.build do
#   string('foo').endby1(string ':)')
# end
# 
# p parser.parse('foofoofoo:)')

__END__
