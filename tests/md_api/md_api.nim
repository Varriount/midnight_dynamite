import midnight_dynamite

const
  input_md = """# Title

This is [a link](http://www.google.es).
"""

when isMainModule:
  echo "Micro testing midnight dynamite."
  var
    md_r = init_md_renderer(md_render_use_xhtml or md_render_safelink)
    md_doc = md_r.document(md_ext_underline or md_ext_space_headers)
    md_buffer = init_md_buffer()

  md_doc.render(md_buffer, input_md)
  md_buffer.reset
  md_doc.render(md_buffer, input_md)
  let low_level_buffer = $md_buffer

  md_buffer.free
  md_doc.free
  md_r.free

  # Repeat using the convenience proc.
  var
    md_params = init_md_params()

  let high_level_buffer = md_params.render(input_md)

  md_params.free

  assert low_level_buffer == high_level_buffer
  echo high_level_buffer

  echo "Done."
