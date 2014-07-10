import midnight_dynamite, os, test_data, strutils

## Generates a documentation file from the embedded tests.
##
## Instead of running the tests this just dumps the output as markdown code
## blocks so they can be rendered as HTML.

const
  indentation = "    "
  indentation_nl = "\n    "
  output_filename_md = "syntax.md"
  output_filename_html = "syntax.html"
  syntax_base_url = "http://daringfireball.net/projects/markdown/syntax#"


proc indented(s: string): string =
  ## Returns the string with an indentation using a four spaces.
  assert(not s.is_nil)
  result = indentation & s.replace("\n", indentation_nl)


proc width(s: string): int =
  ## Returns the maximum number of colums for `s`.
  var
    LINE, COL, POS: int
  for pos in 0 .. <s.len:
    case s[pos]:
    of '\c', '\l':
      LINE.inc
      RESULT = max(RESULT, COL)
      COL = 0
    else:
      COL.inc


proc parse_doc_output(t: Base_test_info): string =
  ## Returns the proper value for the `t.output` field.
  ##
  ## If the documentation is raw, the whole output is passed. Otherwise the
  ## second line is passed along with a generated hyperlink using the third.
  if t.is_raw_doc:
    RESULT = t.output
  else:
    let lines = t.output.split_lines
    assert lines.len > 2
    assert lines[1].len > 0
    assert lines[2].len > 0
    RESULT = "\n### [" & lines[1].strip & "](" &
      syntax_base_url & lines[2].strip & ")\n"


proc build_result_table(info: Base_test_info): string =
  ## Returns input and output of `info` with output twice, once as HTML.
  result = ""
  let
    w2 = info.output.width
  result.add("Input block:\n\n" & info.input.indented & "\n\n")
  result.add("Output block:\n\n" & info.output.indented & "\n\n")
  result.add("Renders as:\n\n<table border='1' width='100%'><tr><td>" &
    info.output & "</td></tr></table>\n\n")
  #else: This doesn't seem to work?
  #  result.add("<table border='1'><tr><th>Output block:</th>" &
  #    "<th>Renders as</th></tr><tr><td>\n\n\n")
  #  #result.add(info.output & "</td><td>\n\n\n")
  #  #result.add(info.output.indented & "\n\n</td></tr></table>\n\n")
  #  result.add(info.output.indented & "\n\n\n</td><td>\n")
  #  result.add(info.output & "</td></tr></table>\n\n")


proc build_result_table(info: Ext_test_info): string =
  ## Outputs base input as plain text, and ext_output as both text and html.
  RESULT = ""
  RESULT.add("Input block:\n\n" & info.input.indented & "\n\n")
  RESULT.add("Normal output:\n\n" & info.base_output.indented & "\n\n")
  RESULT.add("Using extension ``" & $info.extension_flags & "`` ")
  RESULT.add("and render flags ``" & $info.render_flags & "``:\n\n")
  RESULT.add(info.ext_output.indented & "\n\n")
  #RESULT.add("Renders as:\n\n<table border='1' width='100%'><tr><td>" &
  #  info.ext_output & "</td></tr></table>\n\n")


proc build_doc() =
  ## Iterates over test strings generating an md document with them.
  ##
  ## The generated document will have all the tests as input/output blocks in
  ## code.
  var
    MD_PARAMS = init_md_params(render_flags = md_render_default,
      extension_flags = set[md_ext_flag]({}))
    TEXT = ""
  finally:
    MD_PARAMS.free

  for info in test_strings:
    if info.is_doc:
      TEXT.add(info.parse_doc_output & "\n")
    else:
      TEXT.add(info.build_result_table)

  for anon in ext_test_strings:
    let info: Ext_test_info = anon
    if info.is_doc:
      TEXT.add(info.base_output & "\n")
    else:
      TEXT.add(info.build_result_table)

  echo "Generating ", output_filename_md
  output_filename_md.write_file(TEXT)

  echo "Generating ", output_filename_html
  MD_PARAMS.add(TEXT)
  output_filename_html.write_file(MD_PARAMS.full_html)

  let git_md_dest = ".."/".."/"docs"/"syntax.md"
  if git_md_dest.exists_file:
    echo "Copying over git ", git_md_dest
    output_filename_md.copy_file(git_md_dest)


when isMainModule: build_doc()
