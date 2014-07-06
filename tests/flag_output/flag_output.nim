import midnight_dynamite, os, test_data, strutils, sequtils

## Verifies that the certain markdown input generates a specific HTML.
##
## The input/output data is actually in test_data.nim.

proc indented(s: string): string =
  ## Returns the string with an indentation using a tab character and quotes.
  assert(not s.is_nil)
  result = "\t\"\"\"" & s.replace("\n", "\n\t") & "\"\"\""


proc until_eol(s: string, start: int): string =
  ## Returns a version of `s` starting from `start` until first line ending
  var POS = start
  while POS < s.len:
    case s[POS]
    of '\c', '\l': break
    else: POS.inc
  result = s[start..POS]


proc compare_outputs(t1, t2: string) =
  ## Compares `t1` with `t2` and tries to show first visually bad character.
  echo "Failed string comparison. Base reference:"
  echo t1.indented
  echo "Compared to:"
  echo t2.indented
  echo "First difference"
  var
    LINE, COL, POS: int
  while POS < t1.len and POS < t2.len:
    if t1[POS] != t2[POS]:
      break
    case t2[POS]:
    of '\c', '\l':
      LINE.inc
      COL = 0
    else:
      COL.inc
    POS.inc
  echo "Line ", LINE, " col ", COL, ": '", t2.until_eol(POS), "'"


proc run_test(info: Base_test_info): bool =
  ## Makes sure `info` produces the expected output.
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

  MD_DOC.render(MD_BUFFER, info.input)
  let low_level_buffer = $MD_BUFFER

  # Repeat using the convenience proc.
  var
    MD_PARAMS = init_md_params(render_flags = RENDER_FLAGS,
      extension_flags = EXTENSION_FLAGS)
  finally:
    MD_PARAMS.free

  let high_level_buffer = MD_PARAMS.render(info.input)

  if low_level_buffer != high_level_buffer:
    compare_outputs(low_level_buffer, high_level_buffer)
    return
  if low_level_buffer != info.output:
    compare_outputs(low_level_buffer, info.output)
    return

  result = true


proc run_tests() =
  ## Iterates over test_strings trying the test blocks and reporting failures.
  let
    tests: seq[Base_test_info] = @test_strings.filter_it(not it.is_doc)
  var
    SUCCESS: seq[int] = @[]
    FAIL: seq[int] = @[]

  for f, info in tests.pairs:
    try:
      if info.run_test:
        SUCCESS.add(f)
        continue
    except:
      echo "Severe error running test ", f
    FAIL.add(f)

  if FAIL.len < 1:
    echo "All (", tests.len, ") md tests passed."
  else:
    echo "Failed ", FAIL.len, " tests out of ", tests.len
    for f in FAIL:
      echo "\tTest ", f
    quit(1)

when isMainModule: run_tests()
