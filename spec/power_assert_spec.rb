require 'typedocs/enable'
require File.join(File.dirname(__FILE__), '..', 'lib', 'power_assert.rb')

describe PowerAssert::Extractor do
  it do
    ast = subject.extract_from_ast(Ripper.sexp(<<-RUBY), 3)
      describe "hogehoge" do
        it { a.b.c == d }
        it { 1 + 2 == 3 }
      end
    RUBY
    ast.should_not be_nil
    ast[0].should == :brace_block
    ast[2][0][0].should == :binary
    ast[2][0][2].should == :==
    ast[2][0][3].should == [:@int, "3", [3, 22]]
  end
end
