import nake, os, midnight_dynamite, sequtils

type
  In_out = tuple[src, dest, options: string]
    ## The tuple only contains file paths.


template glob_md(basedir: string = nil): expr =
  ## Shortcut to simplify getting lists of files.
  ##
  ## Pass nil to iterate over md files in the current directory. This avoids
  ## prefixing the paths with "./" unnecessarily.
  if baseDir.isNil:
    to_seq(walk_files("*.md"))
  else:
    to_seq(walk_files(basedir/"*.md"))

let
  normal_md_files = concat(glob_md(), glob_md("docs"))
  modules = ["midnight_dynamite.nim", "midnight_dynamite_pkg"/"hoedown.nim"]


proc needs_refresh(target: In_out): bool =
  ## Wrapper around the normal needs_refresh for In_out types.
  if target.options.isNil:
    result = target.dest.needs_refresh(target.src)
  else:
    result = target.dest.needs_refresh(target.src, target.options)


iterator all_md_files(): In_out =
  ## Iterates over all the md files.
  var x: In_out
  for plain_md in normal_md_files:
    x.src = plain_md
    x.dest = plain_md.changeFileExt("html")
    x.options = nil
    yield x


proc build_all_md_files(): seq[In_out] =
  ## Wraps iterator to avoid https://github.com/Araq/Nimrod/issues/866.
  ##
  ## The wrapping forces `for` loops to use a single variable and an extra
  ## `let` line to unpack the tuple.
  result = to_seq(all_md_files())


proc doc() =
  # Generate documentation for the nim modules.
  for module in modules:
    let html_file = module.change_file_ext("html")
    if not html_file.needs_refresh(module): continue
    if not shell("nimrod doc --verbosity:0", module):
      echo "Could not generate module docs for ", module
    else:
      echo "Generated ", html_file

  # Generate html files from the md docs.
  var md = init_md_params()
  for f in build_all_md_files():
    let (md_file, html_file, options) = f
    if not f.needs_refresh: continue
    md.render_file(md_file, html_file)
    echo md_file & " -> " & html_file

  echo "All docs generated"


proc clean() =
  for path in walkDirRec("."):
    let ext = splitFile(path).ext
    if ext == ".html":
      echo "Removing ", path
      path.removeFile()
  echo "Temporary files cleaned"

task "doc", "Generates HTML from the md files.": doc()
task "clean", "Removes temporal files, mostly.": clean()
