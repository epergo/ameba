require "../../spec_helper"

module Ameba::Rule
  subject = UselessConditionInWhen.new

  describe UselessConditionInWhen do
    it "passes if there is not useless condition" do
      s = Source.new %(
        case
        when utc?
          io << " UTC"
        when local?
          Format.new(" %:z").format(self, io) if utc?
        end
      )
      subject.catch(s).should be_valid
    end

    it "fails if there is useless if condition" do
      s = Source.new %(
        case
        when utc?
          io << " UTC" if utc?
        end
      )
      subject.catch(s).should_not be_valid
    end

    it "reports rule, location and message" do
      s = Source.new %(
        case
        when String
          puts "hello"
        when can_generate?
          generate if can_generate?
        end
      ), "source.cr"
      subject.catch(s).should_not be_valid
      error = s.errors.first
      error.rule.should_not be_nil
      error.location.to_s.should eq "source.cr:6:23"
      error.message.should eq "Useless condition in when detected"
    end
  end
end
