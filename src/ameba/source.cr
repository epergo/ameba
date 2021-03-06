module Ameba
  # An entity that represents a Crystal source file.
  # Has path, lines of code and errors reported by rules.
  class Source
    include InlineComments

    # Represents an error caught by Ameba.
    #
    # Each error has the rule that created this error,
    # location of the issue, message and status.
    record Error,
      rule : Rule::Base,
      location : Crystal::Location?,
      message : String,
      status : Symbol? do
      def disabled?
        status == :disabled
      end
    end

    # Path to the source file.
    getter path : String

    # Crystal code (content of a source file).
    getter code : String

    # List of errors reported.
    getter errors = [] of Error

    @lines : Array(String)?
    @ast : Crystal::ASTNode?
    @fullpath : String?

    # Creates a new source by `code` and `path`.
    #
    # For example:
    #
    # ```
    # path = "./src/source.cr"
    # Ameba::Source.new File.read(path), path
    # ```
    #
    def initialize(@code : String, @path = "")
    end

    # Adds a new error to the list of errors.
    #
    # ```
    # source.error rule, location, "Line too long"
    # ```
    #
    def error(rule : Rule::Base, location, message : String, status = nil)
      status ||= :disabled if location_disabled?(location, rule.name)
      errors << Error.new rule, location, message, status
    end

    # Adds a new error to the list of errors using line and column number.
    #
    # ```
    # source.error rule, line_number, column_number, "Bad code"
    # ```
    #
    def error(rule : Rule::Base, l, c, message : String, status = nil)
      location = Crystal::Location.new path, l, c
      error rule, location, message, status
    end

    # Indicates whether source is valid or not.
    # Returns true if the list or errors empty, false otherwise.
    #
    # ```
    # source = Ameba::Source.new code, path
    # source.valid? # => true
    # source.error rule, location, message
    # source.valid? # => false
    # ```
    #
    def valid?
      errors.reject(&.disabled?).empty?
    end

    # Returns lines of code splitted by new line character.
    # Since `code` is immutable and can't be changed, this
    # method caches lines in an instance variable, so calling
    # it second time will not perform a split, but will return
    # lines instantly.
    #
    # ```
    # source = Ameba::Source.new "a = 1\nb = 2", path
    # source.lines # => ["a = 1", "b = 2"]
    # ```
    #
    def lines
      @lines ||= @code.split("\n")
    end

    # Returns AST nodes constructed by `Crystal::Parser`.
    #
    # ```
    # source = Ameba::Source.new code, path
    # source.ast
    # ```
    #
    def ast
      @ast ||=
        Crystal::Parser.new(code)
                       .tap { |parser| parser.filename = @path }
                       .parse
    end

    def fullpath
      @fullpath ||= File.expand_path @path
    end
  end
end
