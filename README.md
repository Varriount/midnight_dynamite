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

Development version
-------------------

Install the [Nimrod compiler](http://nimrod-lang.org/). Then use [Nimrod's
babel package manager](https://github.com/nimrod-code/babel) to install locally
the github checkout:

    $ git clone --recursive https://github.com/gradha/midnight_dynamite.git
    $ cd midnight_dynamite
    $ babel install


Documentation
=============

Documentation is provided as docstrings, you can generate it yourself running
the following commands:

    $ cd `babel path midnight_dynamite`
    $ nimrod doc midnight_dynamite.nim
    $ open midnight_dynamite.html

The minimal practical example is:

    import midnight_dynamite

    when isMainModule:
      var md_params = init_md_params()
      finally: md_params.free
      md_params.render_file("README.md")

Generated versions of the documentation can be browsed online at
[http://gradha.github.io/midnight_dynamite/](http://gradha.github.io/midnight_dynamite/).
You may also browse the [tests directory](tests) for usage examples.


Changes
=======

This is stable version 0.2.0. For a list of changes see the
[docs/changes.md file](docs/changes.md).


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
