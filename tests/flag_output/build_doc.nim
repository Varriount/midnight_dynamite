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


proc parse_doc_output(t: Test_info): string =
  ## Returns the proper value for the `t.output` field.
  ##
  ## If the documentation is raw, the whole output is passed. Otherwise the
  ## second line is passed along with a generated hyperlink using the third.
  if t.is_raw_doc:
    result = t.output
  else:
    let lines = t.output.split_lines
    assert lines.len > 2
    assert lines[1].len > 0
    assert lines[2].len > 0
    result = lines[1] & "\n[See syntax related section](" &
      syntax_base_url & lines[2] & ").\n"


proc build_doc() =
  ## Iterates over test_strings generating a md document with.
  ##
  ## The generated document will have all the tests as input/output blocks in
  ## code.
  var
    RENDER_FLAGS: md_render_flags = {}
    EXTENSION_FLAGS: md_ext_flags = {}
    MD_PARAMS = init_md_params(render_flags = RENDER_FLAGS,
      extension_flags = EXTENSION_FLAGS)
    TEXT = ""
  finally:
    MD_PARAMS.free

  for pos, info in test_strings.pairs:
    if info.is_doc:
      TEXT.add(info.parse_doc_output & "\n")
    else:
      TEXT.add("Input block:\n\n" & info.input.indented & "\n\n")
      TEXT.add("Output block:\n\n" & info.output.indented & "\n\n")

  echo "Generating ", output_filename_md
  output_filename_md.write_file(TEXT)

  echo "Generating ", output_filename_html
  MD_PARAMS.add(TEXT)
  output_filename_html.write_file(MD_PARAMS.full_html)


when isMainModule: build_doc()
