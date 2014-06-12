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


proc init*(r: var md_renderer; render_flags, nesting_level = 0) =
  ## Inits the md_renderer.
  ##
  ## On debug builds this will assert if the renderer is already initialised.
  ## In release builds the behaviour is unknown.
  ##
  ## You need to call free() on the md_renderer when you have finished or you
  ## will leak memory.
  assert r.h.is_nil, "Double initialization attempt"
  r.h = hoedown_html_renderer_new(render_flags.cuint, nesting_level.cint)


proc init_md_renderer*(render_flags, nesting_level = 0): md_renderer =
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
    extension_flags = 0, max_nesting = 16): md_document =
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
