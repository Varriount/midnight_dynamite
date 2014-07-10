import midnight_dynamite, os, test_data, strutils, sequtils

## Verifies that the certain markdown input generates a specific HTML.
##
## The input/output data is actually in test_data.nim.

proc indented(s: string): string =
  ## Returns the string with an indentation using a tab character and quotes.
  assert(not s.is_nil)
  result = s.replace("\t", "<tab>")
  result = "\t\"\"\"" & result.replace("\n", "\n\t") & "\"\"\""


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
  ##
  ## Returns false if something went wrong.
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


proc run_test(info: Ext_test_info): bool =
  ## Runs the test with ext flags and verifies the output.
  ##
  ## Returns false if something went wrong. The test involves making sure the
  ## extended version matches the expected output, and the base version not
  ## matching it.
  var
    MD_PARAMS = init_md_params(render_flags = info.render_flags,
      extension_flags = info.extension_flags)
    BASE_PARAMS = init_md_params(render_flags = {}, extension_flags = {})
  finally:
    MD_PARAMS.free
    BASE_PARAMS.free

  let base_html = BASE_PARAMS.render(info.input)
  if info.base_output != base_html:
    echo "Checking base version:"
    compare_outputs(base_html, info.base_output)
    return

  let ext_html = MD_PARAMS.render(info.input)
  if info.ext_output != ext_html:
    echo "Checking extended version:"
    compare_outputs(ext_html, info.ext_output)
    return

  if ext_html == base_html:
    # Presumably we would never reach this, unless the operator inserting tests
    # is not paying enough attention…
    echo "Eh, rendering output should be different, but base and ext match!"
    echo info.ext_output.indented
    return

  result = true


proc run_basic_tests(): bool =
  ## Iterates over test_strings trying the test blocks and reporting failures.
  ##
  ## Returns false if any test failed.
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
    echo "All (", tests.len, ") md base tests passed."
    result = true
  else:
    echo "Failed ", FAIL.len, " base tests out of ", tests.len
    for f in FAIL:
      echo "\tTest ", f


proc run_ext_tests(): bool =
  ## Iterates over ext_test_strings trying the blocks and reporting failures.
  ##
  ## Returns false if any test failed.
  let
    tests: seq[Ext_test_info] = @ext_test_strings.filter_it(not it.is_doc)
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
    echo "All (", tests.len, ") md ext tests passed."
    result = true
  else:
    echo "Failed ", FAIL.len, " ext tests out of ", tests.len
    for f in FAIL:
      echo "\tTest ", f


proc run_tests() =
  ## Wraps invocation of both base and extension tests.
  var FAIL = false
  if not run_basic_tests(): FAIL = true
  if not run_ext_tests(): FAIL = true
  if FAIL: quit(1)


when isMainModule: run_tests()
