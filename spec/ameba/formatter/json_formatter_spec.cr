require "../../spec_helper"

module Ameba
  def get_result(sources = [Source.new ""])
    file = IO::Memory.new
    formatter = Formatter::JSONFormatter.new file

    formatter.started sources
    sources.each { |source| formatter.source_finished source }
    formatter.finished sources

    JSON.parse file.to_s
  end

  describe Formatter::JSONFormatter do
    context "metadata" do
      it "shows ameba version" do
        get_result["metadata"]["ameba_version"].should eq Ameba::VERSION
      end

      it "shows crystal version" do
        get_result["metadata"]["crystal_version"].should eq Crystal::VERSION
      end
    end

    context "sources" do
      it "shows path to the source" do
        result = get_result [Source.new "", "source.cr"]
        result["sources"].first["path"].should eq "source.cr"
      end

      it "shows rule name" do
        s = Source.new ""
        s.error DummyRule.new, 1, 2, "message1"

        result = get_result [s]
        result["sources"].first["errors"].first["rule_name"].should eq DummyRule.name
      end

      it "shows a message" do
        s = Source.new ""
        s.error DummyRule.new, 1, 2, "message"

        result = get_result [s]
        result["sources"].first["errors"].first["message"].should eq "message"
      end

      it "shows error location" do
        s = Source.new ""
        s.error DummyRule.new, 1, 2, "message"

        result = get_result [s]
        location = result["sources"].first["errors"].first["location"]
        location["line"].should eq 1
        location["column"].should eq 2
      end
    end

    context "summary" do
      it "shows a target sources count" do
        result = get_result [Source.new(""), Source.new("")]
        result["summary"]["target_sources_count"].should eq 2
      end

      it "shows errors count" do
        s1 = Source.new ""
        s1.error DummyRule.new, 1, 2, "message1"
        s1.error DummyRule.new, 1, 2, "message2"

        s2 = Source.new ""
        s2.error DummyRule.new, 1, 2, "message3"

        result = get_result [s1, s2]
        result["summary"]["errors_count"].should eq 3
      end
    end
  end
end
