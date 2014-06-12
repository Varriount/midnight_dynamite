import strutils, argument_parser, tables, os, re, osproc

type
  Global = object ## \
    ## Holds all the global variables of the process.
    params: Tcommandline_results
    hoedown_from: string ## Directory with the base path of hoedown library.

var G: Global

const
  header_dir = "mangled_headers" ## Where the mangled headers will be placed.
  lib_dir = "wrapper" ## Where the original source will be copied.
  exclude_re = ["#include.*[>]", "#define.*__attribute__.*[)]",
    "__attribute__.*[)]"] ## \
    ## Regular expressions that will clean up strange artifacts.
  replacements = [["size_t", "csize"], ["uint8_t", "uint8"],
    ["hoedown_autolink type", "hoedown_autolink autolink_type"]] ## \
    ## Strings that will be replaced in the input during header generation.

  prefix_nim = "{.push importc.}\n" ## String to add before the output nim.
  postfix_nim = """
const HOEDOWN_TABLE_ALIGNMASK = HOEDOWN_TABLE_ALIGN_CENTER
""" ## String to add after the output nim.

  prune_struct = "struct hoedown_html_renderer_state" ## \
  ## Name of the struct we prune.

  name = "mangler"
  version_str* = name & "-0.1.0" ## Program version as a string. \
  ## The format is ``string-digit(.digit)*``.

  version_int* = (major: 0, minor: 1, maintenance: 0) ## \
  ## Program version as an integer tuple.
  ##
  ## Major version changes mean significant new features or a break in
  ## commandline backwards compatibility, either through removal of switches or
  ## modification of their purpose.
  ##
  ## Minor version changes can add switches. Minor
  ## odd versions are development/git/unstable versions. Minor even versions
  ## are public stable releases.
  ##
  ## Maintenance version changes mean bugfixes or non commandline changes.

  param_help = @["-h", "--help"]
  help_help = "Displays commandline help and exits."

  param_version = @["-v", "--version"]
  help_version = "Displays the current version and exists."

  param_source = @["-s", "--source"]
  help_source = "Path to the hoedown base directory. Should contain " &
    "a `src` subdirectory."


proc process_commandline() =
  ## Parses the commandline, modifying the global structure.
  var PARAMS: seq[Tparameter_specification] = @[]
  PARAMS.add(new_parameter_specification(PK_HELP,
    names = param_help, help_text = help_help))
  PARAMS.add(new_parameter_specification(names = param_version,
    help_text = help_version))
  PARAMS.add(new_parameter_specification(PK_STRING, names = param_source,
    help_text = help_source))

  # Parsing.
  G.params = PARAMS.parse

  proc abort(message: string) =
    echo message & "\n"
    params.echo_help
    quit(QuitFailure)

  if G.params.options.has_key(param_version[0]):
    echo "Version ", version_str, "."
    quit()

  if G.params.options.has_key(param_source[0]):
    G.hoedown_from = G.params.options[param_source[0]].str_val
  else:
    abort "You need to specify the path to the hoedown base directory."

  # Input validation.
  if not G.hoedown_from.exists_dir:
    abort "The specified directory doesn't seem valid."

  if not exists_dir(G.hoedown_from/"src"):
    abort "Weird, I was expecting a 'src' subdirectory in the hoedown dir."


proc copy_original_source() =
  ## Copies files form G.hoedown_from/src into lib_dir.
  ##
  ## The target directory is first erased to avoid leaving debris.
  let src_dir = G.hoedown_from/"src"
  echo "Refreshing source from ", src_dir
  lib_dir.remove_dir
  src_dir.copy_dir(lib_dir)


proc mangle_header(src, dest: string) =
  ## Copies a header form src into dest removing system includes.
  ##
  ## The removal is based on finding the string "#include <", which is quite
  ## boring but works.
  var
    re_exclude {.global.}: seq[TRegEx] = @[]

  # Build the regular expressions with groups before and after the match.
  if re_exclude.len < 1:
    for regex in exclude_re:
      re_exclude.add(re("^(.*)(" & regex & ")(.*$)", {reStudy}))

  echo "Mangling ", src, " -> ", dest
  var
    buf = new_string_of_cap(int(src.get_file_size))
    prunning_struct = false
  # While processing replacements, avoid copying the anonymous state struct.
  for line in src.lines:
    if prunning_struct:
      if line[0] == '}':
        prunning_struct = false
    else:
      if line.find(prune_struct) == 0:
        prunning_struct = true
      else:
        var l = line
        for regex in re_exclude:
          l = l.replacef(regex, "$1$3")
        for replacement in replacements:
          l = l.replace(replacement[0], replacement[1])
        buf.add(l & "\n")
  dest.write_file(buf)


proc mangle_headers() =
  ## Mangles source headers to a temporary directory removing system includes.
  assert lib_dir.exists_dir
  header_dir.remove_dir
  header_dir.create_dir

  for kind, path in lib_dir.walk_dir:
    if kind != pcFile: continue
    let (dir, name, ext) = path.split_file
    if ext != ".h": continue
    let dest = header_dir/name & ext
    path.mangle_header(dest)


proc convert_document_header() =
  ## Generates a hoedown.nim file from the preprocessed document.h header.
  ##
  ## After generation prepends prefix_nim and appends postfix_nim to the output
  ## nimrod source. Also appends a list of compile pragmas with the .c files
  ## from lib_dir.
  let
    src = header_dir/"html.h"
    dest = header_dir/"html2.h"
    nim = header_dir/"hoedown.nim"
  var ret = exec_shell_cmd("cpp " & src & " " & dest)
  if ret != 0: quit("Could not run preprocessor on " & src)
  ret = exec_shell_cmd("c2nim -o:" & nim & " " & dest)
  if ret != 0: quit("Could not run c2nim on " & dest)

  # Detect .c files to add compilation pragmas.
  var pragmas = ""
  for kind, path in lib_dir.walk_dir:
    let (dir, name, ext) = path.split_file
    if ext != ".c":
      continue
    pragmas.add("{.compile: \"" & name & ext & "\".}\n")

  # Mangle output file.
  let buf = nim.read_file
  nim.write_file(prefix_nim & "\n" & buf & "\n" & postfix_nim & "\n" & pragmas)


proc main() =
  ## Main entry point of the program.
  process_commandline()
  copy_original_source()
  mangle_headers()
  convert_document_header()

when isMainModule: main()
