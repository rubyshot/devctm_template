# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # See <http://www.pell.portland.or.us/~orc/Code/discount/> for more info
  # about the following options
  OUR_BLUECLOTH_OPTIONS = {
    :remove_links => false, # Allow links, but only via markdown, not via <a>
    :remove_images => false, # Ditto for images
    :smartypants => true, # generate &ldquo and &rdquo
    :pseudoprotocols => true, # allow, e.g., "[STI](abbr:Single Table...)"
    :pandoc_headers => false, # don't consider "%title ..." special
    :header_labels => false, # don't add id to generated h1, h2, etc.
    :escape_html => true, # don't allow arbitrary HTML
    :strict_mode => false, # don't convert _foo_bar into <em>foo</em>bar
    :auto_links => false, # use [](http:) or <http://example.com/> for links
    :safe_links => false # I'd prefer true here, but that interferes with
                         # :pseudoprotocols => true
  }.freeze

  def page_title
    return @page_title || controller.action_name
  end

  def body_id
    return @body_id ? " id=\"#{@body_id}\"" : ''
  end

  def markdown_to_html(markdown)
    return BlueCloth.new(markdown, OUR_BLUECLOTH_OPTIONS).to_html
  end
end
