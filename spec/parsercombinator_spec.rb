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
