Midnight dynamite mangler
=========================

The mangler is a small command line helper for the [Midnight dynamite
project](https://github.com/gradha/midnight_dynamite) which takes the C sources
from the [hoedown lib](https://github.com/hoedown/hoedown), mangles them with
the preprocessor, applies some magical substitutions and produces a
``hoedown.nim`` file. The output Nimrod source won't compile right away, it
still requires some manual tweaking but the hardest part is done by the
mangler.

The purpose of the mangler is to be reused in future versions of the C library
so the work of figuring out how to wrap the library doesn't have to be
rediscovered on each version.

One would hope…

Usage
=====

Compile and run without parameters to see available switches. The switches are
mainly to tell the program where the source directory of the hoedown library
is. Pass the path to the base directory and wait for a ``wrapper`` directory to
be created with the necessary Nimrod and C sources.

Now you do something interesting with all these generated files.
