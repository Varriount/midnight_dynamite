Midnight dynamite readme
========================

**midnight_dynamite** is a [Nimrod](http://nimrod-lang.org) wrapper around the
[hoedown C library](https://github.com/hoedown/hoedown) which renders
[Markdown](http://daringfireball.net/projects/markdown/). The wrapper provides
both the low level C API and a higher level convenience layer. The higher level
API is not yet complete and offers only basic rendering features. Missing
features like table of contents extraction or renderer customization will be
provided in future releases.


License
=======

[MIT license](LICENSE.md).


Installing the library
======================

Stable version
--------------

Install the [Nimrod compiler](http://nimrod-lang.org/). Then use [Nimrod's
Babel package manager](https://github.com/nimrod-code/babel) to install:

    $ babel update
    $ babel install midnight_dynamite


Development version
-------------------

Install the [Nimrod compiler](http://nimrod-lang.org/). Then use [Nimrod's
Babel package manager](https://github.com/nimrod-code/babel) to install locally
the github checkout:

    $ git clone --recursive https://github.com/gradha/midnight_dynamite.git
    $ cd midnight_dynamite
    $ babel install -y

If you don't mind downloading the git repo every time you can also use babel to
install the latest development version:

    $ babel update
    $ babel install -y midnight_dynamite@#head


Documentation
=============

Generated versions of the documentation can be browsed online at
[http://gradha.github.io/midnight_dynamite/](http://gradha.github.io/midnight_dynamite/).
You may also browse the [tests directory](tests) for usage examples.

Documentation is provided as docstrings, you can generate it yourself running
the following commands:

    $ cd `babel path midnight_dynamite`
    $ nimrod doc midnight_dynamite.nim
    $ open midnight_dynamite.html

If you installed using git, run the ``nimrod doc`` command where you cloned the
repo. Here is a minimal practical usage example:

    import midnight_dynamite

    when isMainModule:
      var md_params = init_md_params()
      finally: md_params.free
      md_params.render_file("README.md")


Changes
=======

This is development version 0.2.5. For a list of changes see the
[docs/changes.md file](docs/changes.md). The [hoedown
version](https://github.com/hoedown/hoedown/releases) is 2.0.0.


Git branches
============

This project uses the [git-flow branching
model](https://github.com/nvie/gitflow) with reversed defaults. Stable releases
are tracked in the ``stable`` branch. Development happens in the default
``master`` branch.


Feedback
========

You can send me feedback through [GitHub's issue
tracker](https://github.com/gradha/midnight_dynamite/issues). I also take a
look from time to time to [Nimrod's forums](http://forum.nimrod-lang.org) where
you can talk to other nimrod programmers.
