Midnight dynamite release steps
===============================

Release steps for
[midnight_dynamite](https://github.com/gradha/midnight_dynamite).

* Create new milestone with version number (``vXXX``) at
  https://github.com/gradha/midnight_dynamite/issues/milestones.
* Create new dummy issue `Release versionname` and assign to that milestone.
* ``git flow release start versionname`` (versionname without v).
* Update version numbers:
  * Modify [README.md](../README.md) (s/development/stable/).
  * Modify [midnight_dynamite.nim](../midnight_dynamite.nim).
  * Modify [midnight_dynamite.babel](../midnight_dynamite.babel).
  * Update [docs/changes.md](changes.md) with list of changes and
    version/number.
* ``git commit -av`` into the release branch the version number changes.
* ``git flow release finish versionname`` (the tagname is versionname without
  ``v``).  When specifying the tag message, copy and paste a plain
  text version of the changes log into the message.
* Move closed issues to the release milestone.
* Increase version numbers, ``master`` branch gets +0.0.1.
  * Modify [README.md](../README.md) (s/development/stable/).
  * Modify [midnight_dynamite.nim](../midnight_dynamite.nim).
  * Modify [midnight_dynamite.babel](../midnight_dynamite.babel).
  * Add to [docs/changes.md](changes.md) development version with unknown
    date.
* ``git commit -av`` into ``master`` with *Bumps version numbers for
  development version. Refs #release issue*.
* Regenerate static website.
  * Make sure you don't have any pending changes.
  * Run ``nake web`` and review generated web.
  * ``git add . && git commit``. Tag with `Regenerates website.
    Refs #release_issue`.
* ``git push origin master stable gh-pages --tags``.
* Close the dummy release issue.
* Announce at
  [http://forum.nimrod-lang.org/t/469](http://forum.nimrod-lang.org/t/469).
* Close the milestone on github.
