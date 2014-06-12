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

  md_params* = object ## Convenience bundling of the individual types.
    renderer*: md_renderer
    document*: md_document
    buffer*: md_buffer

  md_render_flag* = enum ## Available flags for creation of renderers.
    md_render_skip_html = HOEDOWN_HTML_SKIP_HTML,
    md_render_html_escape = HOEDOWN_HTML_ESCAPE,
    md_render_expand_tabs = HOEDOWN_HTML_EXPAND_TABS,
    md_render_safelink = HOEDOWN_HTML_SAFELINK,
    md_render_hard_wrap = HOEDOWN_HTML_HARD_WRAP,
    md_render_use_xhtml = HOEDOWN_HTML_USE_XHTML

  md_render_flags* = set[md_render_flag] ## Set of renderer flags.

  md_ext_flag* = enum ## Available flags for document extensions.
    md_ext_tables = HOEDOWN_EXT_TABLES,
    md_ext_fenced_code = HOEDOWN_EXT_FENCED_CODE,
    md_ext_footnotes = HOEDOWN_EXT_FOOTNOTES,
    md_ext_autolink = HOEDOWN_EXT_AUTOLINK,
    md_ext_strikethrough = HOEDOWN_EXT_STRIKETHROUGH,
    md_ext_underline = HOEDOWN_EXT_UNDERLINE,
    md_ext_highlight = HOEDOWN_EXT_HIGHLIGHT,
    md_ext_quote = HOEDOWN_EXT_QUOTE,
    md_ext_superscript = HOEDOWN_EXT_SUPERSCRIPT,
    md_ext_lax_spacing = HOEDOWN_EXT_LAX_SPACING,
    md_ext_no_intra_emphasis = HOEDOWN_EXT_NO_INTRA_EMPHASIS,
    md_ext_space_headers = HOEDOWN_EXT_SPACE_HEADERS,
    md_ext_disable_indented_code = HOEDOWN_EXT_DISABLE_INDENTED_CODE

  md_ext_flags* = set[md_ext_flag] ## Set of extension flags.

const
  md_render_default* = set[md_render_flag]({}) ## Default empty render flags.
  md_ext_default = set[md_ext_flag]({}) ## Default empty extension flags.


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
  r.h = hoedown_html_renderer_new(cast[cuint](render_flags), nesting_level.cint)


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
    extension_flags = md_ext_default; max_nesting = 16): md_document =
  ## Generates a document from a renderer configuration.
  ##
  ## On debug builds this will assert if the renderer is not initialised. In
  ## release builds the behaviour is likely a crash.
  ##
  ## You need to call free() on the document when you have finished or you will
  ## leak memory.
  assert(not renderer.h.is_nil, "Renderer not initialized")
  result.h = hoedown_document_new(renderer.h,
    cast[cuint](extension_flags), max_nesting.csize)


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


proc init*(p: var md_params;
    render_flags = md_render_default; render_nesting_level = 0;
    extension_flags = md_ext_default; document_max_nesting = 16;
    buffer_unit = 16) =
  ## Inits the md_params.
  ##
  ## On debug builds this will assert if the params are already initialised.
  ## In release builds the behaviour is unknown.
  ##
  ## You need to call free() on the md_params when you have finished or you
  ## will leak memory.
  assert p.renderer.h.is_nil, "Double initialization attempt"
  p.renderer.init(render_flags, render_nesting_level)
  p.document = p.renderer.document(extension_flags, document_max_nesting)
  p.buffer.init(buffer_unit)


proc init_md_params*(
    render_flags = md_render_default; render_nesting_level = 0;
    extension_flags = md_ext_default; document_max_nesting = 16;
    buffer_unit = 16): md_params =
  ## Convenience wrapper over *init()*.
  result.init(render_flags, render_nesting_level,
    extension_flags, document_max_nesting, buffer_unit)


proc free*(p: var md_params) =
  ## Frees resources allocated by the parameters.
  ##
  ## You are required to call this or you will leak memory. If you are not
  ## sure, you can call this many times over and it won't hurt.
  if p.renderer.h.is_nil: return
  p.renderer.free
  p.document.free
  p.buffer.free


proc reset*(p: var md_params) =
  ## Cleans up the rendered buffer for reuse.
  ##
  ## This proc will assert in debug builds if `buffer` has not been
  ## initialised. In release builds it will likely crash.
  p.buffer.reset


proc add*(p: var md_params; md_text: string) =
  ## Adds the `md_text` to the markdown rendered buffer.
  ##
  ## Call `p.reset()` if you want to clean the stored text previously.
  ##
  ## If the params have not been initialized, this proc will assert in debug
  ## builds and will likely crash in release
  p.document.render(p.buffer, md_text)


proc `$`*(p: md_params): string =
  ## Returns the rendered string so far as a Nimrod string.
  ##
  ## This proc will assert in debug builds if the buffer has not been
  ## initialised. In release builds it will likely crash.
  result = $p.buffer


proc render*(p: var md_params; md_text: string): string =
  ## Convenience proc which resets the buffer, renders it, and returns it.
  p.reset
  p.add(md_text)
  result = $p
