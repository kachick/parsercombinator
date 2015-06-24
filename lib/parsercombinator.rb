# coding: us-ascii
# Copyright (c) 2015 Kenichi Kamiya

require 'ostruct'

# @todo Thinking to use StringScanner
#       String#{slice,[]} generating new string objects :<.
module ParserCombinator
  Result = Struct.new :string, :position
  class Pass < Result; end
  class Fail < Result; end
  
  class Error < StandardError; end
  class InvalidOperationError < Error; end
  

  module Combinationable
    def choice(*parsers)
      raise ArgumentError unless parsers.all?{|p|p.kind_of? Parsable}
      
      ->string, position {
        parsers.each do |parser|
          case ret = parser.call(string, position)
          when Pass
            return ret
          else
            next
          end
        end
        
        Fail.new
      }.extend Parsable
    end
    
    # def sequence(*parsers)
    #   raise ArgumentError unless parsers.all?{|p|p.kind_of? Parsable}
    #   
    #   ->string, position {
    #     new_pos = nil
    #     parsers.map do |parser|
    #       ret = parser.call(string, (new_pos || position))
    #       return ret unless ret.kind_of? Pass
    #       new_pos = ret.position
    #       ret
    #     end
    #   }.extend Parsable
    # end
    # 

    def option(parser)
      raise ArgumentError unless parser.kind_of? Parsable

      ->string, position {
        case ret = parser.call(string, position)
        when Fail
          Pass.new(*ret.values)
        else
          ret
        end
      }.extend Parsable
    end
    
    def many(parser)
      raise ArgumentError unless parser.kind_of? Parsable
      
      ->string, position {
        pos = position
        rets = []
        loop do
          case ret = parser.call(string, pos)
          when Pass
            rets << ret.string
            pos = ret.position
          else
            return Pass.new(rets, pos)
          end
        end
        
      }.extend Parsable
    end
  end

  module Parsable
    include Combinationable
    
    def parse(string, position=0)
      call string, position
    end
    
    alias_method :run, :parse
    
    def |(parser)
      raise ArgumentError unless parser.kind_of? Parsable
      
      choice self, parser
    end
    
    def +(parser)
      raise ArgumentError unless parser.kind_of? Parsable
      
      # sequence self, other
      ->string, position {
        ret = parse(string, position)
        return Fail.new if ret.kind_of? Fail
        oret = parser.parse(string, ret.position)
        return Fail.new if oret.kind_of? Fail
        Pass.new [ret.string, oret.string], oret.position
      }.extend Parsable
    end
    
    def optional
      option self
    end
  end
  
  
  class << self
    # @return [Parsable]
    def build(&block)
      ret = BuilderDSL.new.instance_exec(OpenStruct.new, &block)
      if ret.kind_of? Parsable
        ret
      else
        raise InvalidOperationError
      end
    end
  end
  
  class BuilderDSL
    include Combinationable

    def rest
      ->string, position {
        str = string[position..-1]
        Pass.new str, false
      }.extend Parsable
    end

    def token(str)
      ->string, position {
        if string[position, str.length] == str
          Pass.new str, position + str.length
        else
          Fail.new nil, position
        end
      }.extend Parsable
    end

    def regexp(rxp)
      unless %r(\A/\\A).match(rxp.inspect)
        raise InvalidOperationError, 'the regexp should start with /\A/'
      end
      
      ->string, position {
        if rxp.match(string[position..-1])
          Pass.new $~[0], position + $~[0].length
        else
          Fail.new nil, position
        end
      }.extend Parsable
    end

    def lazy(&block)
      raise ArgumentError unless block_given?
    
      ->string, position {
        parser = block.call
        parser.call(string, position)
      }.extend Parsable
    end
    
    # @todo I think a better way, each parser will have map via block
    def map(parser, &block)
      raise ArgumentError unless block_given?
      
      ->string, position {
        ret = parser.call(string, position)
        nstr = block.call ret.string
        ret.string = nstr
        ret
        # block.call parser.call(string, position).string
      }.extend Parsable
    end
  end

end
