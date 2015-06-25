# coding: us-ascii

require_relative 'spec_helper'

describe ParserCombinator do
  before :each do
    @dsl = ParserCombinator::BuilderDSL.new
  end
  
  let :dsl do
    @dsl
  end
  
  context 'DSL' do
    context '#string' do
      before :each do
        @parser = dsl.string 'foo'
      end
      
      it 'returns a parser for the string' do
        expect(@parser.parse('foo').matched).to eq('foo')
        expect(@parser.parse('xfoo').fail?).to be(true)
      end
    end

    context '#regexp' do
      before :each do
        @parser = dsl.regexp(/\Afoo[2-5]/i)
      end
      
      it 'returns a parser for the regexp' do
        expect(@parser.parse('FoO4').matched).to eq('FoO4')
        expect(@parser.parse('foo1').fail?).to be(true)
      end
      
      it 'raises an InvalidOperationError if the regexp not start with \A' do
        expect{dsl.regexp(/^foo[2-5]/)}.to raise_error(ParserCombinator::InvalidOperationError)
      end
    end

    context '#sequence' do
      before :each do
        @parser = dsl.sequence(dsl.string('foo'), dsl.string('bar'))
      end
      
      it 'returns a parser for the string, the parser passes when unmatched' do
        expect(@parser.parse('foobar').matched).to eq(['foo', 'bar'])
        expect(@parser.parse('bar').fail?).to be(true)
        expect(@parser.parse('fooXbar').fail?).to be(true)
      end
    end
  end
  
  context 'Combinators' do
    context '#optional' do
      before :each do
        @parser = dsl.string('foo').optional + dsl.rest
      end
      
      it 'returns a parser for the string, the parser passes when unmatched' do
        expect(@parser.parse('foo').matched).to eq(['foo', ''])
        expect(@parser.parse('xfoo').pass?).to be(true)
        expect(@parser.parse('xfoo').matched).to eq([nil, 'xfoo'])
      end
    end

    context '#many' do
      before :each do
        @parser = dsl.string('foo').many
      end
      
      it 'returns a parser for the strings' do
        expect(@parser.parse('foo').matched).to eq(['foo'])
        expect(@parser.parse('xfoo').pass?).to be(true)
        expect(@parser.parse('foox').matched).to eq(['foo'])
        expect(@parser.parse('foofoofoo').matched).to eq(['foo', 'foo', 'foo'])
      end
    end

    context '#many1' do
      before :each do
        @parser = dsl.string('foo').many1
      end
      
      it 'returns a parser for the strings' do
        expect(@parser.parse('foo').matched).to eq(['foo'])
        expect(@parser.parse('xfoo').fail?).to be(true)
        expect(@parser.parse('foox').matched).to eq(['foo'])
        expect(@parser.parse('foofoofoo').matched).to eq(['foo', 'foo', 'foo'])
      end
    end

    context '#endby1' do
      before :each do
        @parser = dsl.string('foo').endby1(dsl.string 'bar')
      end
      
      it 'returns a parser for the strings' do
        expect(@parser.parse('foobar').matched).to eq(['foo'])
        expect(@parser.parse('xfoobar').fail?).to be(true)
        expect(@parser.parse('foobarfoobar').matched).to eq(['foo', 'foo'])
      end
    end
    
    context '#sepby1' do
      before :each do
        @parser = dsl.string('foo').sepby1(dsl.string 'bar')
      end
      
      it 'returns a parser for the strings' do
        expect(@parser.parse('foo').matched).to eq(['foo'])
        expect(@parser.parse('foobar').pass?).to be(true)
        expect(@parser.parse('foobarfoobarfoo').matched).to eq(['foo', 'foo', 'foo'])
      end
    end

    context '#|' do
      before :each do
        @parser = dsl.string('foo') | dsl.string('bar')
      end
      
      it 'returns a parser for the strings' do
        expect(@parser.parse('foo').matched).to eq('foo')
        expect(@parser.parse('xfoo').fail?).to be(true)
        expect(@parser.parse('foobar').matched).to eq('foo')
        expect(@parser.parse('barfoo').matched).to eq('bar')
      end
    end
  end
end
