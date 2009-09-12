require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationHelper do
  include ApplicationHelper

  describe 'page_title' do
    # TODO
  end

  describe 'body_id' do
    # TODO
  end

  describe 'markdown_to_html' do
    it "doesn't remove links" do
      markdown_to_html('[test](http://example.com/foo "title")').should ==
        "<p><a href=\"http://example.com/foo\" title=\"title\">test</a></p>"
    end

    it "doesn't remove images" do
      markdown_to_html('![Alt text](/path/to/img.jpg)').should ==
        "<p><img src=\"/path/to/img.jpg\" alt=\"Alt text\" /></p>"
    end

    it "uses smartypants quoting" do
      markdown_to_html('"I am teh smart"').should ==
        "<p>&ldquo;I am teh smart&rdquo;</p>"
    end

    it "allows pseudoprotocols" do
      markdown_to_html('[STI](abbr:Single Table Inheritance)').should ==
        "<p><abbr title=\"Single Table Inheritance\">STI</abbr></p>"
    end

    it "doesn't recognize pandoc headers" do
      markdown_to_html("%title My title\n%author\n%date June 15, 2006\n").should ==
        "<p>%title My title\n%author\n%date June 15, 2006</p>"
    end

    it "doesn't add an id attr to headers" do
      markdown_to_html("# header").should ==
        "<h1>header</h1>"
    end

    it "escapes html" do
      markdown_to_html("<i>really?</i>").should ==
        "<p>&lt;i>really?&lt;/i></p>"
    end

    it "doesn't use strict mode (so _ in middle of identifier doesn't surprise us)" do
      markdown_to_html("_hello_world").should ==
        "<p>_hello_world</p>"
    end

    it "doesn't auto-link" do
      markdown_to_html("http://example.com/").should ==
        "<p>http://example.com/</p>"
    end

    it "(Unfortunately) doesn't enforce safe links (because that conflicts with pseudoprotocols)" do
      markdown_to_html("[test](fuproto:arg)").should ==
        "<p><a href=\"fuproto:arg\">test</a></p>"
    end
    
  end

end
