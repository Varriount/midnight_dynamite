import midnight_dynamite

const
  md = """# Title

This is [a link](http://www.google.es).
"""

when isMainModule:
  echo "Micro testing midnight dynamite."
  var
    r = hoedown_html_renderer_new(0, 0)
    doc = hoedown_document_new(r, 0, 16)
    html = hoedown_buffer_new(16)

  doc.hoedown_document_render(html, cast[ptr uint8](md.cstring), md.len)
  echo html.hoedown_buffer_cstr

  html.hoedown_buffer_free
  doc.hoedown_document_free
  r.hoedown_html_renderer_free

  echo "Done."
