import midnight_dynamite, os

type
  Test_info = tuple[input, output: string;
    render_flags: md_render_flags; extension_flags: md_ext_flags]

const
  test_strings: array[2, Test_info] = [
    ("meh", "<p>meh</p>\n", md_render_flags({}), md_ext_flags({})),

    ("""
This is a regular paragraph.

<table>
    <tr>
        <td>Foo</td>
    </tr>
</table>

This is another regular paragraph.
""", """
<p>This is a regular paragraph.</p>

<table>
    <tr>
        <td>Foo</td>
    </tr>
</table>

<p>This is another regular paragraph.</p>
""",
md_render_flags({}), md_ext_flags({})),
    ]

proc run_test(pair: Test_info): bool =
  ## Makes sure `pair` produces the expected output.

  var
    RENDER_FLAGS: md_render_flags = {}
    EXTENSION_FLAGS: md_ext_flags = {}
    MD_R = init_md_renderer(RENDER_FLAGS)
    MD_DOC = MD_R.document(EXTENSION_FLAGS)
    MD_BUFFER = init_md_buffer()

  finally:
    MD_BUFFER.free
    MD_DOC.free
    MD_R.free

  MD_DOC.render(MD_BUFFER, pair.input)
  let low_level_buffer = $MD_BUFFER

  # Repeat using the convenience proc.
  var
    MD_PARAMS = init_md_params(render_flags = RENDER_FLAGS,
      extension_flags = EXTENSION_FLAGS)
  finally:
    MD_PARAMS.free

  let high_level_buffer = MD_PARAMS.render(pair.input)

  if low_level_buffer != high_level_buffer:
    echo "low level '", low_level_buffer, "' != '", high_level_buffer, "'"
    return
  if low_level_buffer != pair.output:
    echo "low level '", low_level_buffer, "' != '", pair.output, "'"
    return

  result = true


proc run_tests() =
  ## Iterates over test_strings trying them all and reporting failures.
  var
    SUCCESS: seq[int] = @[]
    FAIL: seq[int] = @[]

  for f, pair in test_strings.pairs:
    try:
      if pair.run_test:
        SUCCESS.add(f)
        continue
    except:
      echo "Severe error running test ", f
    FAIL.add(f)

  if FAIL.len < 1:
    echo "All md tests passed."
  else:
    echo "Failed ", FAIL.len, " tests out of ", test_strings.len
    for f in FAIL:
      echo "\tTest ", f, ": '", test_strings[f].input, "'"

when isMainModule: run_tests()
