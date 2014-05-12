require 'ripper'
require 'patm'
require 'typedocs'

module PowerAssert
  include Typedocs::DSL
  tdoc.typedef :@AST, 'Array'
  tdoc.typedef :@Bool, 'TrueClass|FalseClass'

  def self.current_context
    Thread.current[:power_assert_context] ||= Context.new
  end

  class Context
    def add(expr, value)
    end
  end

  class Extractor
    include Typedocs::DSL

    tdoc 'String -> Numeric -> @AST'
    def extract(path, line_no)
      whole_ast = Ripper.sexp(File.read(path))
      extract_from_ast(whole_ast, line_no)
    end

    tdoc '@AST -> Numeric -> ?@AST|nil -> @AST|nil'
    def extract_from_ast(ast, line_no, block_ast = nil)
      p = ::Patm
      _1 = p._1
      _2 = p._2
      __ = p._any
      case ast
      when m = p.match([p.or(:do_block, :brace_block), p._any, p._any[:exprs]])
        m[:exprs].each do|expr|
          found = extract_from_ast(expr, line_no, ast)
          return found if found
        end
      when m = p.match([:binary, _1, __, _2])
        found =extract_from_ast(m._1, line_no, block_ast) ||
          extract_from_ast(m._2, line_no, block_ast)
        return found if found
      when m = p.match([:@int, __, [_1, __]])
        return block_ast if block_ast && m._1 == line_no
      else
        if ast.is_a?(Array) && ast.size > 0
          exprs =
            if ast[0].is_a?(Symbol) # some struct
              ast[1..-1]
            else
              ast
            end
          exprs.each do|expr|
            next unless expr.is_a?(Array)
            found = extract_from_ast(expr, line_no, nil)
            return found if found
          end
        end
      end
      nil
    end
  end
  class Injector
    include Typedocs::DSL

    tdoc '@AST -> Tree'
    def parse(ast)
      Tree.new
    end
  end

  class Tree
    include Typedocs::DSL

    tdoc 'String'
    def to_source
      ""
    end
  end
end
