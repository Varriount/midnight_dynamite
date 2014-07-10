import midnight_dynamite_pkg/hoedown, os, strtabs, streams, parsecfg, times,
  strutils

## `midnight_dynamite <https://github.com/gradha/midnight_dynamite>`_ is a
## wrapper of the markdown rendering `hoedown library
## <https://github.com/hoedown/hoedown>`_.
##
## This module provides a more Nimrodic interface to the `low level interface
## <midnight_dynamite_pkg/hoedown.html>`_. Usually you will create an
## `md_params object <#md_params>`_ with the `init_md_params proc
## <#init_md_params>`_. You can then call on the ``md_params`` object
## convenience procs like `full_html <#full_html>`_ to render a whole HTML file
## to memory or `render_file <#render_file>`_ to deal with files.
##
## There are different flavours of markdown. The document `Original markdown
## syntax <docs/syntax.html>`_ explains what is supported by the library and
## gives some examples of `render <#md_render_flag>`_ and `extension
## <#md_ext_flag>`_ flags that can be used.


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
export hoedown_escape_html
export hoedown_escape_href
export hoedown_html_is_tag
export hoedown_html_renderer_new
export hoedown_html_toc_renderer_new
export hoedown_html_renderer_free
export hoedown_html_smartypants
export hoedown_stack_free
export hoedown_stack_grow
export hoedown_stack_new
export hoedown_stack_push
export hoedown_stack_pop
export hoedown_stack_top
export hoedown_version

type
  md_renderer* = object ## Wraps a raw hoedown_renderer type. \
    ##
    ## Initialize this type with `init_md_renderer(...) <#init_md_renderer>`_.
    h: ptr hoedown_renderer

  md_document* = object ## Wraps a raw hoedown_document type. \
    ##
    ## Build an object of this type with `document(...) <#document>`_.
    h: ptr hoedown_document

  md_buffer* = object ## Wraps a raw hoedown_buffer type. \
    ##
    ## Initialize this type with `init_md_buffer(...) <#init_md_buffer>`_.
    h: ptr hoedown_buffer

  md_params* = object ## Convenience bundling of the individual raw types. \
    ## In general the only public field you might want to change yourself is
    ## ``html_config``, but you can do that through the init methods anyway.
    renderer: md_renderer ## Not public because we hack it for customization.
    document*: md_document
    buffer*: md_buffer ## Stores the rendered HTML so far.
    html_config*: Pstring_table ## HTML decoration configuration. \
    ## The format of the configuration should be the same as the one returned
    ## by package/docutils/rstgen.defaultConfig(). However, only the
    ## ``doc.file`` attribute will be used to wrap the output in `full_html()`.

  md_render_flag* = enum ## \
    ## Available flags for creation of renderers.
    ##
    ## These flags change how the rendering generates HTML. You can see
    ## examples of these flags in the `Original markdown syntax
    ## <docs/syntax.html>`_ document.
    md_render_skip_html, ## Skips HTML tags altogether.
    md_render_html_escape, ## Escapes HTML tags in output.
    md_render_expand_tabs, ## Buggy, at the moment all tabs get expanded.
    md_render_safelink, ## Allows hyperlinks only to a set of safe protocols.
    md_render_hard_wrap, ## Treats all newlines as <br> tags.
    md_render_use_xhtml, ## Generates XHTML tags instead of HTML tags.

  md_render_flags* = set[md_render_flag] ## \
    ## Type alias for a set of renderer flags.

  md_ext_flag* = enum ## \
    ## Available flags for document extensions.
    ##
    ## These flags enable different ways of parsing markdown input. You can see
    ## examples of these flags in the `Original markdown syntax
    ## <docs/syntax.html>`_ document.
    md_ext_tables, ## Enables Markdown Extra style tables.
    md_ext_fenced_code, ## Enables fenced code blocks.
    md_ext_footnotes, ## Enables Markdown Extra style footnotes.
    md_ext_autolink, ## Enables parsing URLs into hyperlinks.
    md_ext_strikethrough, ## Enables ~~striking~~ text.
    md_ext_underline, ## Replaces ``<em>`` tags into ``<u>`` tags in output.
    md_ext_highlight, ## Enables ==marking== text.
    md_ext_quote, ## Replaces ``"`` characters into ``<q>`` tags in output.
    md_ext_superscript, ## Enables carets to start superscript text.
    md_ext_lax_spacing, ## Allows no empty lines between HTML and markdown.
    md_ext_no_intra_emphasis, ## Disables emphasis between words.
    md_ext_space_headers, ## Headers require a space after the hash character.
    md_ext_disable_indented_code, ## Disables indented code blocks.

  md_ext_flags* = set[md_ext_flag] ## \
    ## Type alias for a set of extension flags.

const
  md_render_default* = set[md_render_flag]({}) ## Default empty render flags.
  md_ext_default* = set[md_ext_flag]({md_ext_autolink, md_ext_highlight,
    md_ext_lax_spacing, md_ext_no_intra_emphasis, md_ext_fenced_code,
    md_ext_strikethrough}) ## Default GitHub syntax friendly extension flags.

  version_str* = "0.2.3" ## Version as a string. \
  ## The format is ``digit(.digit)*``.

  version_int* = (major: 0, minor: 2, maintenance: 3) ## \
  ## Version as an integer tuple.
  ##
  ## Major version changes mean significant new features or a break in
  ## backwards compatibility.
  ##
  ## Minor version changes can add switches. Minor
  ## odd versions are development/git/unstable versions. Minor even versions
  ## are public stable releases.
  ##
  ## Maintenance version changes usually mean bugfixes.

  default_html_config_str = slurp("nimdoc.cfg") ## \
  ## Reads the default html configuration for output headers.
  html_config_key = "doc.file" ## Value used for HTML decoration.


var
  default_html_config: Pstring_table ## default_html_config_str parsed.


proc load_html_config(mem_string: string): Pstring_table =
  ## Parses the configuration and retuns it as a Pstring_table.
  ##
  ## If something goes wrong, will likely raise an exception. Otherwise it
  ## always return a valid object.
  result = newStringTable(modeStyleInsensitive)
  var f = newStringStream(mem_string)
  if f.isNil: raise newException(EInvalidValue, "cannot stream string")

  var p: TCfgParser
  open(p, f, "static slurped config")
  while true:
    var e = next(p)
    case e.kind
    of cfgEof:
      break
    of cfgSectionStart:   ## a ``[section]`` has been parsed
      discard
    of cfgKeyValuePair:
      result[e.key] = e.value
    of cfgOption:
      quit("command: " & e.key & ": " & e.value)
    of cfgError:
      quit(e.msg)
  close(p)


proc init*(r: var md_renderer;
    render_flags = md_render_default; nesting_level = 0) =
  ## Inits the md_renderer.
  ##
  ## On debug builds this will assert if the renderer is already initialised.
  ## In release builds the behaviour is unknown.
  ##
  ## You need to call `free() <#free,md_renderer>`_ on the md_renderer when you
  ## have finished or you will leak memory.
  assert r.h.is_nil, "Double initialization attempt"
  assert((1 shl int(md_render_skip_html)) == int(HOEDOWN_HTML_SKIP_HTML))
  assert((1 shl int(md_render_html_escape)) == int(HOEDOWN_HTML_ESCAPE))
  assert((1 shl int(md_render_expand_tabs)) == int(HOEDOWN_HTML_EXPAND_TABS))
  assert((1 shl int(md_render_safelink)) == int(HOEDOWN_HTML_SAFELINK))
  assert((1 shl int(md_render_hard_wrap)) == int(HOEDOWN_HTML_HARD_WRAP))
  assert((1 shl int(md_render_use_xhtml)) == int(HOEDOWN_HTML_USE_XHTML))
  r.h = hoedown_html_renderer_new(cast[cuint](render_flags), nesting_level.cint)


proc init_md_renderer*(render_flags = md_render_default,
    nesting_level = 0): md_renderer =
  ## Convenience wrapper over `init() <#init,md_renderer>`_
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
  ## You need to call `free() <#free,md_document>`_ on the document when you
  ## have finished or you will leak memory.
  assert(not renderer.h.is_nil, "Renderer not initialized")
  assert((1 shl int(md_ext_tables)) == int(HOEDOWN_EXT_TABLES))
  assert((1 shl int(md_ext_fenced_code)) == int(HOEDOWN_EXT_FENCED_CODE))
  assert((1 shl int(md_ext_footnotes)) == int(HOEDOWN_EXT_FOOTNOTES))
  assert((1 shl int(md_ext_autolink)) == int(HOEDOWN_EXT_AUTOLINK))
  assert((1 shl int(md_ext_strikethrough)) == int(HOEDOWN_EXT_STRIKETHROUGH))
  assert((1 shl int(md_ext_underline)) == int(HOEDOWN_EXT_UNDERLINE))
  assert((1 shl int(md_ext_highlight)) == int(HOEDOWN_EXT_HIGHLIGHT))
  assert((1 shl int(md_ext_quote)) == int(HOEDOWN_EXT_QUOTE))
  assert((1 shl int(md_ext_superscript)) == int(HOEDOWN_EXT_SUPERSCRIPT))
  assert((1 shl int(md_ext_lax_spacing)) == int(HOEDOWN_EXT_LAX_SPACING))
  assert((1 shl int(md_ext_space_headers)) == int(HOEDOWN_EXT_SPACE_HEADERS))
  assert((1 shl int(md_ext_no_intra_emphasis)) ==
    int(HOEDOWN_EXT_NO_INTRA_EMPHASIS))
  assert((1 shl int(md_ext_disable_indented_code)) ==
    int(HOEDOWN_EXT_DISABLE_INDENTED_CODE))
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
  ## You need to call `free() <#free,md_buffer>`_ on the md_buffer when you
  ## have finished or you will leak memory.
  assert r.h.is_nil, "Double initialization attempt"
  r.h = hoedown_buffer_new(unit)


proc init_md_buffer*(unit = 16): md_buffer =
  ## Convenience wrapper over `init() <#init,md_buffer>`_.
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
  ## `buffer.reset() <#reset,md_buffer>`_ if you want to clean it previously.
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
    buffer_unit = 16; html_config = Pstring_table(nil)) =
  ## Inits the parameter structure.
  ##
  ## On debug builds this will assert if the params are already initialised.
  ## In release builds the behaviour is unknown.
  ##
  ## You need to call `free() <#free,md_params>`_ on the initialised params
  ## when you have finished or you will leak memory.
  ##
  ## Usage example:
  ##
  ## .. code-block:: nimrod
  ##   var params: md_params
  ##   params.init
  ##   finally: params.free
  assert p.renderer.h.is_nil, "Double initialization attempt"
  p.renderer.init(render_flags, render_nesting_level)
  p.document = p.renderer.document(extension_flags, document_max_nesting)
  p.buffer.init(buffer_unit)
  p.html_config = html_config


proc init_md_params*(
    render_flags = md_render_default; render_nesting_level = 0;
    extension_flags = md_ext_default; document_max_nesting = 16;
    buffer_unit = 16, html_config = Pstring_table(nil)): md_params =
  ## Convenience wrapper over `init() <#init,md_params>`_.
  ##
  ## Usage example:
  ##
  ## .. code-block:: nimrod
  ##   var params = init_md_params()
  ##   finally: params.free
  result.init(render_flags, render_nesting_level,
    extension_flags, document_max_nesting, buffer_unit, html_config)


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
  ## Call `p.reset() <#reset,md_params>`_ if you want to clean the stored text
  ## previously.
  ##
  ## If the params have not been initialized, this proc will assert in debug
  ## builds and will likely crash in release
  ##
  ## Note that each string will be added as an independant block, if you need
  ## to render a whole markdown element you should not split it.
  ##
  ## Usage example:
  ##
  ## .. code-block:: nimrod
  ##   var params = init_md_params()
  ##   params.add "Oppa"
  ##   params.add "*Gangnam style*"
  ##   echo($params)
  ##   # <p>Oppa</p>
  ##   #
  ##   # <p><em>Gangnam style</em></p>
  ##   #
  p.document.render(p.buffer, md_text)


proc `$`*(p: md_params): string =
  ## Returns the rendered string so far as a Nimrod string.
  ##
  ## This proc will assert in debug builds if the buffer has not been
  ## initialised. In release builds it will likely crash.
  ##
  ## Usage example:
  ##
  ## .. code-block:: nimrod
  ##   var params = init_md_params()
  ##   params.add "Hey *sexy lady*"
  ##   echo($params)
  ##   # <p>Hey <em>sexy lady</em></p>
  result = $p.buffer


proc full_html*(p: md_params): string =
  ## Similar to `$ <#$,md_params>`_ but returns the full HTML instead of an
  ## embeddable part.
  ##
  ## The *decoration* is extracted from the `p.html_config` field, ``doc.file``
  ## value. If `p.html_config` is nil, a default will be provided extracted
  ## from Nimrod's rst generator.
  ##
  ## If the `html_config` field does not contain a ``doc.file`` value an
  ## assertion will be raised in debug builds, and you will likely crash on
  ## release builds.
  ##
  ## Usage example:
  ##
  ## .. code-block:: nimrod
  ##   var params = init_md_params()
  ##   params.add "Hey *sexy lady*"
  ##   echo params.full_html
  let content = $p
  var config = p.html_config
  if config.is_nil:
    # Load the default configuration, parsing it if necessary.
    if default_html_config.is_nil:
      default_html_config = default_html_config_str.load_html_config
    config = default_html_config
  assert(not config.is_nil, "Bad HTML rendering configuration")
  assert config.has_key(html_config_key), "Invalid html configuration"
  let decoration = config[html_config_key]
  result = decoration % ["title", "", "content", content,
    "date", getDateStr(), "time", getClockStr()]


proc render*(p: var md_params; md_text: string): string =
  ## Convenience proc which resets the buffer, renders it, and returns it.
  ##
  ## Usage example:
  ##
  ## .. code-block:: nimrod
  ##   var params = init_md_params()
  ##   echo params.render("Hey *sexy lady*")
  ##   # <p>Hey <em>sexy lady</em></p>
  p.reset
  p.add(md_text)
  result = $p


proc render_file*(p: var md_params; input_filename: string,
    output_filename = "") =
  ## Convenience proc which reads `input_filename` and generates an HTML file.
  ##
  ## If `output_filename` is the empty string, the output filename will be
  ## `input_filename` with the extension changed to ``.html``.
  ##
  ## Usage example:
  ##
  ## .. code-block:: nimrod
  ##   var params = init_md_params()
  ##   params.render_file("README.md")
  ##   # Generates README.html file
  assert(not input_filename.is_nil, "Input filename can't be nil")
  assert(not output_filename.is_nil, "Output filename can't be nil")
  var dest = output_filename
  if dest.len < 1:
    dest = input_filename.change_file_ext("html")
  p.reset
  p.add(input_filename.read_file)
  dest.write_file(p.full_html)
