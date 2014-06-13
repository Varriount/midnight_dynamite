import midnight_dynamite, os

const
  input_md = """# Title

This is [a link](http://www.google.es).
"""

proc test_renderers() =
  ## Tests rendering using the lower level api and higher level api.
  const
    render_flags = {md_render_use_xhtml, md_render_safelink}
    extension_flags = {md_ext_underline, md_ext_space_headers}
  var
    md_r = init_md_renderer(render_flags)
    md_doc = md_r.document(extension_flags)
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
    md_params = init_md_params(render_flags = render_flags,
      extension_flags = extension_flags)

  let high_level_buffer = md_params.render(input_md)

  md_params.free

  assert low_level_buffer == high_level_buffer
  echo high_level_buffer


proc test_files() =
  ## Renders directly files. This requires a certain directory structure.
  let
    original = ".."/".."/"README.md"
    copied = original.extract_filename
    specific = "specific.html"

  if not copied.exists_file:
    original.copy_file_with_permissions(copied)

  # Repeat using the convenience proc.
  var md_params = init_md_params()
  finally: md_params.free

  md_params.render_file(copied)
  md_params.render_file(copied, specific)


when isMainModule:
  echo "Testing in memory rendering"
  test_renderers()
  echo "Testing file rendering"
  test_files()
  echo "Done."
