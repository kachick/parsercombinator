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
    map(token('(') + h.expression + token(')')) do |ret|
      ret
    end
  end

  atom = map(integer){|s|s.to_i} | parenthesis

  h.expression = map(atom + many(operator + atom)) do |ret|
    ret.flatten 1
  end

end

p parser.run('1+2-(3+1-(4))')
# p parser.run('foobar')
# p parser.run(DATA.read)


__END__
