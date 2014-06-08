import strutils, argument_parser, tables, os

type
  Global = object ## \
    ## Holds all the global variables of the process.
    params: Tcommandline_results
    hoedown_from: string ## Directory with the base path of hoedown library.

var G: Global

const
  header_dir = "mangled_headers" ## Where the mangled headers will be placed.
  hoedown_dir = "hoedown_lib" ## Where the original source will be copied.

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
  ## Copies files form G.hoedown_from/src into hoedown_dir.
  ##
  ## The target directory is first erased to avoid leaving debris.
  let src_dir = G.hoedown_from/"src"
  echo "Refreshing source from ", src_dir
  hoedown_dir.remove_dir
  src_dir.copy_dir(hoedown_dir)


proc main() =
  ## Main entry point of the program.
  process_commandline()
  copy_original_source()

when isMainModule: main()
