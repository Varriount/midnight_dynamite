Midnight dynamite release steps
===============================

Release steps for
[midnight_dynamite](https://github.com/gradha/midnight_dynamite).

* Create new milestone with version number.
* Create new dummy issue `Release versionname` and assign to that milestone.
* ``git flow release start versionname`` (versionname without v).
* Update version numbers:

  * Modify `README.md <../README.md>`_ (s/development/stable/).
  * Modify `midnight_dynamite.nim <../midnight_dynamite.nim>`_.
  * Modify `midnight_dynamite.babel <../midnight_dynamite.babel>`_.
  * Update `docs/changes.md <changes.md>`_ with list of changes and
    version/number.

* ``git commit -av`` into the release branch the version number changes.
* ``git flow release finish versionname`` (the tagname is versionname without
  ``v``).  When specifying the tag message, copy and paste a text version of
  the changes log into the message. Add md item markers.
* Move closed issues to the release milestone.
* ``git push origin master stable --tags``.

* Increase version numbers, ``master`` branch gets +0.0.1.

  * Modify `README.md <../README.md>`_ (s/development/stable/).
  * Modify `midnight_dynamite.nim <../midnight_dynamite.nim>`_.
  * Modify `midnight_dynamite.babel <../midnight_dynamite.babel>`_.
  * Add to `docs/changes.md <changes.md>`_ development version with unknown
    date.

* ``git commit -av`` into ``master`` with *Bumps version numbers for
  development version. Refs #release issue*.
* Check out ``gh-pages`` branch and run
  [gh_nimrod_doc_pages](https://github.com/gradha/gh_nimrod_doc_pages). Then
  commit changes.
* ``git push origin master stable gh-pages --tags``.
* Close the dummy release issue.
* Announce at
  [http://forum.nimrod-lang.org/t/469](http://forum.nimrod-lang.org/t/469).
* Close the milestone on github.
