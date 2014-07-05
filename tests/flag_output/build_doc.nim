import midnight_dynamite, os, test_data, strutils

"""
Generates a documentation file from the embedded tests.

Instead of running the tests this just dumps the output as markdown code blocks
so they can be rendered as HTML.
"""

const
  indentation = "    "
  indentation_nl = "\n    "
  output_filename_md = "syntax.md"
  output_filename_html = "syntax.html"


proc indented(s: string): string =
  ## Returns the string with an indentation using a four spaces.
  assert(not s.is_nil)
  result = indentation & s.replace("\n", indentation_nl)


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

  TEXT.add("# Markdown syntax examples\n")

  for pos, info in test_strings.pairs:
    TEXT.add("## Test case " & $(pos + 1) & "\n")
    TEXT.add("Input block:\n\n" & info.input.indented & "\n\n")
    TEXT.add("Output block:\n\n" & info.output.indented & "\n\n")
 
  echo "Generating ", output_filename_md
  output_filename_md.write_file(TEXT)

  echo "Generating ", output_filename_html
  MD_PARAMS.add(TEXT)
  output_filename_html.write_file(MD_PARAMS.full_html)


when isMainModule: build_doc()
