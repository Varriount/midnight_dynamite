{.push importc.}

type
  hoedown_buferror_t* {.size: sizeof(cint).} = enum
    HOEDOWN_BUF_ENOMEM = - 1,
    HOEDOWN_BUF_OK = 0
  hoedown_realloc_callback* = proc (a2: pointer; a3: csize): pointer
  hoedown_free_callback* = proc (a2: pointer)
  hoedown_buffer* = object
    data*: ptr uint8
    size*: csize
    asize*: csize
    unit*: csize
    data_realloc*: hoedown_realloc_callback
    data_free*: hoedown_free_callback
    buffer_free*: hoedown_free_callback


proc hoedown_buffer_init*(buffer: ptr hoedown_buffer; unit: csize;
                          data_realloc: hoedown_realloc_callback;
                          data_free: hoedown_free_callback;
                          buffer_free: hoedown_free_callback)
proc hoedown_buffer_new*(unit: csize): ptr hoedown_buffer
proc hoedown_buffer_free*(buf: ptr hoedown_buffer)
proc hoedown_buffer_reset*(buf: ptr hoedown_buffer)
proc hoedown_buffer_grow*(buf: ptr hoedown_buffer; neosz: csize): cint
proc hoedown_buffer_put*(buf: ptr hoedown_buffer; data: pointer; len: csize)
proc hoedown_buffer_puts*(buf: ptr hoedown_buffer; str: cstring)
proc hoedown_buffer_putc*(buf: ptr hoedown_buffer; c: uint8)
proc hoedown_buffer_prefix*(buf: ptr hoedown_buffer; prefix: cstring): cint
proc hoedown_buffer_slurp*(buf: ptr hoedown_buffer; len: csize)
proc hoedown_buffer_cstr*(buf: ptr hoedown_buffer): cstring
proc hoedown_buffer_printf*(buf: ptr hoedown_buffer; fmt: cstring) {.varargs.}
const
  HOEDOWN_AUTOLINK_SHORT_DOMAINS* = (1 shl 0)

proc hoedown_autolink_is_safe*(link: ptr uint8; link_len: csize): cint
proc hoedown_autolink_c_www*(rewind_p: ptr csize; link: ptr hoedown_buffer;
                            data: ptr uint8; offset: csize; size: csize;
                            flags: cuint): csize {.importc:"hoedown_autolink__www".}
proc hoedown_autolink_c_email*(rewind_p: ptr csize; link: ptr hoedown_buffer;
                              data: ptr uint8; offset: csize; size: csize;
                              flags: cuint): csize {.importc:"hoedown_autolink__email".}
proc hoedown_autolink_c_url*(rewind_p: ptr csize; link: ptr hoedown_buffer;
                            data: ptr uint8; offset: csize; size: csize;
                            flags: cuint): csize {.importc:"hoedown_autolink__url".}
type
  hoedown_extensions* = enum
    HOEDOWN_EXT_TABLES = (1 shl 0), HOEDOWN_EXT_FENCED_CODE = (1 shl 1),
    HOEDOWN_EXT_FOOTNOTES = (1 shl 2), HOEDOWN_EXT_AUTOLINK = (1 shl 3),
    HOEDOWN_EXT_STRIKETHROUGH = (1 shl 4), HOEDOWN_EXT_UNDERLINE = (1 shl 5),
    HOEDOWN_EXT_HIGHLIGHT = (1 shl 6), HOEDOWN_EXT_QUOTE = (1 shl 7),
    HOEDOWN_EXT_SUPERSCRIPT = (1 shl 8), HOEDOWN_EXT_LAX_SPACING = (1 shl 9),
    HOEDOWN_EXT_NO_INTRA_EMPHASIS = (1 shl 10),
    HOEDOWN_EXT_SPACE_HEADERS = (1 shl 11),
    HOEDOWN_EXT_DISABLE_INDENTED_CODE = (1 shl 12)
  hoedown_listflags* = enum
    HOEDOWN_LIST_ORDERED = (1 shl 0), HOEDOWN_LI_BLOCK = (1 shl 1)
  hoedown_tableflags* = enum
    HOEDOWN_TABLE_ALIGN_LEFT = 1, HOEDOWN_TABLE_ALIGN_RIGHT = 2,
    HOEDOWN_TABLE_ALIGN_CENTER = 3,
    HOEDOWN_TABLE_HEADER = 4
  hoedown_autolink* = enum
    HOEDOWN_AUTOLINK_NONE, HOEDOWN_AUTOLINK_NORMAL, HOEDOWN_AUTOLINK_EMAIL
  hoedown_renderer* = object
    opaque*: pointer
    blockcode*: proc (ob: ptr hoedown_buffer; text: ptr hoedown_buffer;
                      lang: ptr hoedown_buffer; opaque: pointer)
    blockquote*: proc (ob: ptr hoedown_buffer; text: ptr hoedown_buffer;
                       opaque: pointer)
    blockhtml*: proc (ob: ptr hoedown_buffer; text: ptr hoedown_buffer;
                      opaque: pointer)
    header*: proc (ob: ptr hoedown_buffer; text: ptr hoedown_buffer;
                   level: cint; opaque: pointer)
    hrule*: proc (ob: ptr hoedown_buffer; opaque: pointer)
    list*: proc (ob: ptr hoedown_buffer; text: ptr hoedown_buffer; flags: cuint;
                 opaque: pointer)
    listitem*: proc (ob: ptr hoedown_buffer; text: ptr hoedown_buffer;
                     flags: cuint; opaque: pointer)
    paragraph*: proc (ob: ptr hoedown_buffer; text: ptr hoedown_buffer;
                      opaque: pointer)
    table*: proc (ob: ptr hoedown_buffer; header: ptr hoedown_buffer;
                  body: ptr hoedown_buffer; opaque: pointer)
    table_row*: proc (ob: ptr hoedown_buffer; text: ptr hoedown_buffer;
                      opaque: pointer)
    table_cell*: proc (ob: ptr hoedown_buffer; text: ptr hoedown_buffer;
                       flags: cuint; opaque: pointer)
    footnotes*: proc (ob: ptr hoedown_buffer; text: ptr hoedown_buffer;
                      opaque: pointer)
    footnote_def*: proc (ob: ptr hoedown_buffer; text: ptr hoedown_buffer;
                         num: cuint; opaque: pointer)
    autolink*: proc (ob: ptr hoedown_buffer; link: ptr hoedown_buffer;
                     autolink_type: hoedown_autolink; opaque: pointer): cint
    codespan*: proc (ob: ptr hoedown_buffer; text: ptr hoedown_buffer;
                     opaque: pointer): cint
    double_emphasis*: proc (ob: ptr hoedown_buffer; text: ptr hoedown_buffer;
                            opaque: pointer): cint
    emphasis*: proc (ob: ptr hoedown_buffer; text: ptr hoedown_buffer;
                     opaque: pointer): cint
    underline*: proc (ob: ptr hoedown_buffer; text: ptr hoedown_buffer;
                      opaque: pointer): cint
    highlight*: proc (ob: ptr hoedown_buffer; text: ptr hoedown_buffer;
                      opaque: pointer): cint
    quote*: proc (ob: ptr hoedown_buffer; text: ptr hoedown_buffer;
                  opaque: pointer): cint
    image*: proc (ob: ptr hoedown_buffer; link: ptr hoedown_buffer;
                  title: ptr hoedown_buffer; alt: ptr hoedown_buffer;
                  opaque: pointer): cint
    linebreak*: proc (ob: ptr hoedown_buffer; opaque: pointer): cint
    link*: proc (ob: ptr hoedown_buffer; link: ptr hoedown_buffer;
                 title: ptr hoedown_buffer; content: ptr hoedown_buffer;
                 opaque: pointer): cint
    raw_html_tag*: proc (ob: ptr hoedown_buffer; tag: ptr hoedown_buffer;
                         opaque: pointer): cint
    triple_emphasis*: proc (ob: ptr hoedown_buffer; text: ptr hoedown_buffer;
                            opaque: pointer): cint
    strikethrough*: proc (ob: ptr hoedown_buffer; text: ptr hoedown_buffer;
                          opaque: pointer): cint
    superscript*: proc (ob: ptr hoedown_buffer; text: ptr hoedown_buffer;
                        opaque: pointer): cint
    footnote_ref*: proc (ob: ptr hoedown_buffer; num: cuint; opaque: pointer): cint
    entity*: proc (ob: ptr hoedown_buffer; entity: ptr hoedown_buffer;
                   opaque: pointer)
    normal_text*: proc (ob: ptr hoedown_buffer; text: ptr hoedown_buffer;
                        opaque: pointer)
    doc_header*: proc (ob: ptr hoedown_buffer; opaque: pointer)
    doc_footer*: proc (ob: ptr hoedown_buffer; opaque: pointer)

  hoedown_document* = object


proc hoedown_document_new*(renderer: ptr hoedown_renderer; extensions: cuint;
                           max_nesting: csize): ptr hoedown_document
proc hoedown_document_render*(doc: ptr hoedown_document; ob: ptr hoedown_buffer;
                              document: ptr uint8; doc_size: csize)
proc hoedown_document_free*(doc: ptr hoedown_document)
type
  hoedown_html_flags* {.size: sizeof(cint).} = enum
    HOEDOWN_HTML_SKIP_HTML = (1 shl 0), HOEDOWN_HTML_ESCAPE = (1 shl 1),
    HOEDOWN_HTML_EXPAND_TABS = (1 shl 2), HOEDOWN_HTML_SAFELINK = (1 shl 3),
    HOEDOWN_HTML_HARD_WRAP = (1 shl 4), HOEDOWN_HTML_USE_XHTML = (1 shl 5)
  hoedown_html_tag* {.size: sizeof(cint).} = enum
    HOEDOWN_HTML_TAG_NONE = 0, HOEDOWN_HTML_TAG_OPEN, HOEDOWN_HTML_TAG_CLOSE

proc hoedown_html_is_tag*(tag_data: ptr uint8; tag_size: csize; tagname: cstring): cint
proc hoedown_html_renderer_new*(render_flags: cuint; nesting_level: cint): ptr hoedown_renderer
proc hoedown_html_toc_renderer_new*(nesting_level: cint): ptr hoedown_renderer
proc hoedown_html_renderer_free*(renderer: ptr hoedown_renderer)
proc hoedown_html_smartypants*(ob: ptr hoedown_buffer; text: ptr uint8;
                               size: csize)
const HOEDOWN_TABLE_ALIGNMASK = HOEDOWN_TABLE_ALIGN_CENTER

# Force using relative path, see https://github.com/Araq/Nimrod/issues/1262.
# In the future the directory might have to be removed.
{.compile: "midnight_dynamite_pkg/autolink.c".}
{.compile: "midnight_dynamite_pkg/buffer.c".}
{.compile: "midnight_dynamite_pkg/document.c".}
{.compile: "midnight_dynamite_pkg/escape.c".}
{.compile: "midnight_dynamite_pkg/html.c".}
{.compile: "midnight_dynamite_pkg/html_blocks.c".}
{.compile: "midnight_dynamite_pkg/html_smartypants.c".}
{.compile: "midnight_dynamite_pkg/stack.c".}
{.compile: "midnight_dynamite_pkg/version.c".}
