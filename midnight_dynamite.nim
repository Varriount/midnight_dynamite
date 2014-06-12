import midnight_dynamite_pkg/hoedown

# Symbol list extracted from original hoedown.def.
export hoedown_autolink_is_safe
export hoedown_autolink_c_www
export hoedown_autolink_c_email
export hoedown_autolink_c_url
export hoedown_buffer_grow
export hoedown_buffer_new
export hoedown_buffer_cstr
export hoedown_buffer_prefix
export hoedown_buffer_put
export hoedown_buffer_puts
export hoedown_buffer_putc
export hoedown_buffer_free
export hoedown_buffer_reset
export hoedown_buffer_slurp
export hoedown_buffer_printf
export hoedown_document_new
export hoedown_document_render
export hoedown_document_free
#export hoedown_escape_html
#export hoedown_escape_href
export hoedown_html_is_tag
export hoedown_html_renderer_new
export hoedown_html_toc_renderer_new
export hoedown_html_renderer_free
export hoedown_html_smartypants
#export hoedown_stack_free
#export hoedown_stack_grow
#export hoedown_stack_new
#export hoedown_stack_push
#export hoedown_stack_pop
#export hoedown_stack_top
#export hoedown_version

type
  md_renderer* = object ## Wraps a raw C hoedown_renderer type.
    h: ptr hoedown_renderer

  md_document* = object ## Wraps a raw hoedown_document type.
    h: ptr hoedown_document

  md_buffer* = object ## Wraps a raw hoedown_buffer type.
    h: ptr hoedown_buffer

  md_render_flags* = distinct int ## Valid type for md_renderer construction.
  md_doc_flags* = distinct int ## Valid type for document extensions.

const
  md_render_default* = md_render_flags(0)
  md_render_skip_html* = md_render_flags(HOEDOWN_HTML_SKIP_HTML)
  md_render_html_escape* = md_render_flags(HOEDOWN_HTML_ESCAPE)
  md_render_expand_tabs* = md_render_flags(HOEDOWN_HTML_EXPAND_TABS)
  md_render_safelink* = md_render_flags(HOEDOWN_HTML_SAFELINK)
  md_render_hard_wrap* = md_render_flags(HOEDOWN_HTML_HARD_WRAP)
  md_render_use_xhtml* = md_render_flags(HOEDOWN_HTML_USE_XHTML)
  md_ext_tables* = md_doc_flags(HOEDOWN_EXT_TABLES)
  md_ext_fenced_code* = md_doc_flags(HOEDOWN_EXT_FENCED_CODE)
  md_ext_footnotes* = md_doc_flags(HOEDOWN_EXT_FOOTNOTES)
  md_ext_autolink* = md_doc_flags(HOEDOWN_EXT_AUTOLINK)
  md_ext_strikethrough* = md_doc_flags(HOEDOWN_EXT_STRIKETHROUGH)
  md_ext_underline* = md_doc_flags(HOEDOWN_EXT_UNDERLINE)
  md_ext_highlight* = md_doc_flags(HOEDOWN_EXT_HIGHLIGHT)
  md_ext_quote* = md_doc_flags(HOEDOWN_EXT_QUOTE)
  md_ext_superscript* = md_doc_flags(HOEDOWN_EXT_SUPERSCRIPT)
  md_ext_lax_spacing* = md_doc_flags(HOEDOWN_EXT_LAX_SPACING)
  md_ext_no_intra_emphasis* = md_doc_flags(HOEDOWN_EXT_NO_INTRA_EMPHASIS)
  md_ext_space_headers* = md_doc_flags(HOEDOWN_EXT_SPACE_HEADERS)
  md_ext_disable_indented_code* =
    md_doc_flags(HOEDOWN_EXT_DISABLE_INDENTED_CODE)


proc init*(r: var md_renderer;
    render_flags = md_render_default; nesting_level = 0) =
  ## Inits the md_renderer.
  ##
  ## On debug builds this will assert if the renderer is already initialised.
  ## In release builds the behaviour is unknown.
  ##
  ## You need to call free() on the md_renderer when you have finished or you
  ## will leak memory.
  assert r.h.is_nil, "Double initialization attempt"
  r.h = hoedown_html_renderer_new(render_flags.cuint, nesting_level.cint)


proc init_md_renderer*(render_flags = md_render_default,
    nesting_level = 0): md_renderer =
  ## Convenience wrapper over *init()*.
  result.init(render_flags, nesting_level)


proc free*(r: var md_renderer) =
  ## Frees resources allocated by this renderer.
  ##
  ## You are required to call this or you will leak memory. If you are not
  ## sure, you can call this many times over and it won't hurt.
  if r.h.is_nil: return
  r.h.hoedown_html_renderer_free
  r.h = nil


proc document*(renderer: md_renderer;
    extension_flags = md_doc_flags(0), max_nesting = 16): md_document =
  ## Generates a document from a renderer configuration.
  ##
  ## On debug builds this will assert if the renderer is not initialised. In
  ## release builds the behaviour is likely a crash.
  ##
  ## You need to call free() on the document when you have finished or you will
  ## leak memory.
  assert(not renderer.h.is_nil, "Renderer not initialized")
  result.h = hoedown_document_new(renderer.h,
    extension_flags.cuint, max_nesting.csize)


proc free*(r: var md_document) =
  ## Frees resources allocated by this document.
  ##
  ## You are required to call this or you will leak memory. If you are not
  ## sure, you can call this many times over and it won't hurt.
  if r.h.is_nil: return
  r.h.hoedown_document_free
  r.h = nil


proc init*(r: var md_buffer; unit = 16) =
  ## Inits the md_buffer.
  ##
  ## On debug builds this will assert if the buffer is already initialised.
  ## In release builds the behaviour is unknown.
  ##
  ## You need to call free() on the md_buffer when you have finished or you
  ## will leak memory.
  assert r.h.is_nil, "Double initialization attempt"
  r.h = hoedown_buffer_new(unit)


proc init_md_buffer*(unit = 16): md_buffer =
  ## Convenience wrapper over *init()*.
  result.init(unit)


proc free*(r: var md_buffer) =
  ## Frees resources allocated by this buffer.
  ##
  ## You are required to call this or you will leak memory. If you are not
  ## sure, you can call this many times over and it won't hurt.
  if r.h.is_nil: return
  r.h.hoedown_buffer_free
  r.h = nil


proc render*(document: md_document; buffer: md_buffer; md_text: string) =
  ## Renders the `document` into the `buffer`.
  ##
  ## If `buffer` already contains text, it will be preserved. Call
  ## `buffer.reset()` if you want to clean it previously.
  ##
  ## If `md_text` is nil, or `document` or `buffer` have not been initialized,
  ## this proc will assert in debug builds and will likely crash in release
  ## builds.
  assert(not document.h.is_nil, "Uninitialized document")
  assert(not buffer.h.is_nil, "Uninitialized buffer")
  assert(not md_text.is_nil, "Can't process nil text")
  document.h.hoedown_document_render(buffer.h,
    cast[ptr uint8](md_text.cstring), md_text.len)


proc `$`*(buffer: md_buffer): string =
  ## Returns the contents of the `md_buffer` as a Nimrod string.
  ##
  ## This proc will assert in debug builds if the buffer has not been
  ## initialised. In release builds it will likely crash.
  assert(not buffer.h.is_nil, "Buffer was not initialised")
  let ret = buffer.h.hoedown_buffer_cstr
  assert(not ret.is_nil, "Error reading from converted buffer")
  result = $ret


proc reset*(buffer: md_buffer) =
  ## Cleans up the buffer for reuse.
  ##
  ## This proc will assert in debug builds if `buffer` has not been
  ## initialised. In release builds it will likely crash.
  assert(not buffer.h.is_nil, "Buffer was not initialised")
  buffer.h.hoedown_buffer_reset


proc `or`*(a, b: md_render_flags): md_render_flags =
  ## Allows or'ing two md_render_flags.
  result = md_render_flags(int(a) or int(b))


proc `or`*(a, b: md_doc_flags): md_doc_flags =
  ## Allows or'ing two md_doc_flags.
  result = md_doc_flags(int(a) or int(b))
