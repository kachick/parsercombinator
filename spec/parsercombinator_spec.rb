# coding: us-ascii

require_relative 'spec_helper'

describe ParserCombinator do
  context 'DSL' do
    before :each do
      @context = ParserCombinator::BuilderDSL.new
    end

    context '#string' do
      before :each do
        @parser = @context.string 'foo'
      end
      
      it 'returns a parser for the string' do
        expect(@parser.parse('foo').matched).to eq('foo')
        expect(@parser.parse('xfoo').fail?).to be(true)
      end
    end

    context '#regexp' do
      before :each do
        @parser = @context.regexp /\Afoo[2-5]/i
      end
      
      it 'returns a parser for the regexp' do
        expect(@parser.parse('FoO4').matched).to eq('FoO4')
        expect(@parser.parse('foo1').fail?).to be(true)
      end
      
      it 'raises an InvalidOperationError if the regexp not start with \A' do
        expect{@context.regexp /^foo[2-5]/}.to raise_error(ParserCombinator::InvalidOperationError)
      end
    end

    context '#many' do
      before :each do
        @parser = @context.string('foo').many
      end
      
      it 'returns a parser for the strings' do
        expect(@parser.parse('foo').matched).to eq(['foo'])
        expect(@parser.parse('xfoo').pass?).to be(true)
        expect(@parser.parse('foox').matched).to eq(['foo'])
        expect(@parser.parse('foofoofoo').matched).to eq(['foo', 'foo', 'foo'])
      end
    end
    
    context '#|' do
      before :each do
        @parser = @context.string('foo') | @context.string('bar')
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
