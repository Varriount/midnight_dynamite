import midnight_dynamite

## Holds the markdown rendering test data.
##
## If the Base_test_info tuple has a zero length input, it means that the entry
## is not to be tested and instead is to be dumped in the output syntax.md file
## generated as documentation.
##
## Such documentation blocks can be raw or parsed. Raw blocks are passed
## verbatim to the output markdown. Parsed blocks start with a newline and
## consists of two more lines, the first being passed verbatim, the second
## containing the syntax reference intralink.

type
  Ext_test_info* =
    tuple[input, base_output, ext_output: string;
      render_flags: md_render_flags; extension_flags: md_ext_flags]
  Base_test_info* = tuple[input, output: string]


proc is_doc*(x: Base_test_info): bool =
  ## Returns true if `x` contains data for a documentation section.
  result = x.input.len < 1

proc is_doc*(x: Ext_test_info): bool =
  ## Returns true if `x` contains data for a documentation section.
  result = x.input.len < 1

proc is_raw_doc*(x: Base_test_info): bool =
  ## Returns true if the `output` field from `x` has to be passed in unmodified.
  ##
  ## Non raw documentation consists of two lines, the first will be passed raw,
  ## the second contains an embedded reference to the original syntax
  ## documentation.
  assert x.is_doc
  result = not (x.output[0] in {'\c', '\l'})


# Here comes the embedded data for the tests.
const
  test_strings*: array[67, Base_test_info] = [
    ("", """
# Original markdown syntax

The [midnight_dynamite](https://github.com/gradha/midnight_dynamite) wrapper
around the [hoedown library](https://github.com/hoedown/hoedown) supports the
[complete original markdown
syntax](http://daringfireball.net/projects/markdown/basics). What follows are
the syntax examples given out in the [full syntax
page](http://daringfireball.net/projects/markdown/syntax) replicating the
section hierarchy so you can find easily a specific example.
"""),

    ("", "## Overview"),
    ("", "\n### Inline HTML\nhtml"),

    ("""
This is a regular paragraph.

<table>
    <tr>
        <td>Foo</td>
    </tr>
</table>

This is another regular paragraph.
""", """
<p>This is a regular paragraph.</p>

<table>
    <tr>
        <td>Foo</td>
    </tr>
</table>

<p>This is another regular paragraph.</p>
"""), # ---

    ("", "\n### Automatic escaping for special characters\nautoescape"),

    ("http://images.google.com/images?num=30&q=larry+bird",
      "<p>http://images.google.com/images?num=30&amp;q=larry+bird</p>\n"), # ---

    ("""
<a href="http://images.google.com/images?num=30&q=larry+bird">images</a>
""", """
<p><a href="http://images.google.com/images?num=30&q=larry+bird">images</a></p>
"""), # ---

    ("""
<a href="http://images.google.com/images?num=30&q=larry+bird">images</a>
""", """
<p><a href="http://images.google.com/images?num=30&q=larry+bird">images</a></p>
"""), # ---

    ("&copy; AT&T 4 < 5", "<p>&copy; AT&amp;T 4 &lt; 5</p>\n"), # ---

    ("", "## Block Elements"),
    ("", "\n### Paragraphs and line breaks\np"),

    ("""
in
a
single
line

second paragraph""", """
<p>in
a
single
line</p>

<p>second paragraph</p>
"""), # ---

    ("", "\n### Headers\nheader"),

    ("""
This is an H1
=============

This is an H2
-------------

body""", """
<h1>This is an H1</h1>

<h2>This is an H2</h2>

<p>body</p>
"""), # ---


    ("""
# This is an H1

## This is an H2

###### This is an H6

body""", """
<h1>This is an H1</h1>

<h2>This is an H2</h2>

<h6>This is an H6</h6>

<p>body</p>
"""), # ---

    ("""
# This is an H1 #

## This is an H2 ##

### This is an H3 ######

body""", """
<h1>This is an H1</h1>

<h2>This is an H2</h2>

<h3>This is an H3</h3>

<p>body</p>
"""), # ---

    ("", "## Overview"),
    ("", "\n### Blockquotes\nblockquote"),

    ("""
> This is a blockquote with two paragraphs. Lorem ipsum dolor sit amet,
> consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.
> Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.
>
> Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse
> id sem consectetuer libero luctus adipiscing.

extra""", """
<blockquote>
<p>This is a blockquote with two paragraphs. Lorem ipsum dolor sit amet,
consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.
Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.</p>

<p>Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse
id sem consectetuer libero luctus adipiscing.</p>
</blockquote>

<p>extra</p>
"""), # ---

    ("""
> This is a blockquote with two paragraphs. Lorem ipsum dolor sit amet,
consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.
Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.

> Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse
id sem consectetuer libero luctus adipiscing.

extra""", """
<blockquote>
<p>This is a blockquote with two paragraphs. Lorem ipsum dolor sit amet,
consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.
Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.</p>

<p>Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse
id sem consectetuer libero luctus adipiscing.</p>
</blockquote>

<p>extra</p>
"""), # ---

    ("""
> This is the first level of quoting.
>
> > This is nested blockquote.
>
> Back to the first level.

extra""", """
<blockquote>
<p>This is the first level of quoting.</p>

<blockquote>
<p>This is nested blockquote.</p>
</blockquote>

<p>Back to the first level.</p>
</blockquote>

<p>extra</p>
"""), # ---

    ("""
> ## This is a header.
>
> 1.   This is the first list item.
> 2.   This is the second list item.
>
> Here's some example code:
>
>     return shell_exec("echo $input | $markdown_script");
extra""", """
<blockquote>
<h2>This is a header.</h2>

<ol>
<li>  This is the first list item.</li>
<li>  This is the second list item.</li>
</ol>

<p>Here&#39;s some example code:</p>

<pre><code>return shell_exec(&quot;echo $input | $markdown_script&quot;);
</code></pre>

<p>extra</p>
</blockquote>
"""), # ---

    ("", "\n### Lists\nlist"),

    ("""
*   Red
*   Green
*   Blue
""", """
<ul>
<li>  Red</li>
<li>  Green</li>
<li>  Blue</li>
</ul>
"""), # ---

    ("""
+   Red
+   Green
+   Blue
""", """
<ul>
<li>  Red</li>
<li>  Green</li>
<li>  Blue</li>
</ul>
"""), # ---

    ("""
-   Red
-   Green
-   Blue
""", """
<ul>
<li>  Red</li>
<li>  Green</li>
<li>  Blue</li>
</ul>
"""), # ---

    ("""
1.  Bird
2.  McHale
3.  Parish
""", """
<ol>
<li> Bird</li>
<li> McHale</li>
<li> Parish</li>
</ol>
"""), # ---

    ("""
1.  Bird
1.  McHale
1.  Parish
""", """
<ol>
<li> Bird</li>
<li> McHale</li>
<li> Parish</li>
</ol>
"""), # ---

    ("""
3.  Bird
1.  McHale
8.  Parish
""", """
<ol>
<li> Bird</li>
<li> McHale</li>
<li> Parish</li>
</ol>
"""), # ---

    ("""
*   Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
    Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi,
    viverra nec, fringilla in, laoreet vitae, risus.
*   Donec sit amet nisl. Aliquam semper ipsum sit amet velit.
    Suspendisse id sem consectetuer libero luctus adipiscing.
""", """
<ul>
<li>  Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi,
viverra nec, fringilla in, laoreet vitae, risus.</li>
<li>  Donec sit amet nisl. Aliquam semper ipsum sit amet velit.
Suspendisse id sem consectetuer libero luctus adipiscing.</li>
</ul>
"""), # ---

    ("""
*   Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi,
viverra nec, fringilla in, laoreet vitae, risus.
*   Donec sit amet nisl. Aliquam semper ipsum sit amet velit.
Suspendisse id sem consectetuer libero luctus adipiscing.
""", """
<ul>
<li>  Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi,
viverra nec, fringilla in, laoreet vitae, risus.</li>
<li>  Donec sit amet nisl. Aliquam semper ipsum sit amet velit.
Suspendisse id sem consectetuer libero luctus adipiscing.</li>
</ul>
"""), # ---

    ("""
*   Bird

*   Magic
""", """
<ul>
<li><p>Bird</p></li>
<li><p>Magic</p></li>
</ul>
"""), # ---

    ("""
1.  This is a list item with two paragraphs. Lorem ipsum dolor
    sit amet, consectetuer adipiscing elit. Aliquam hendrerit
    mi posuere lectus.

    Vestibulum enim wisi, viverra nec, fringilla in, laoreet
    vitae, risus. Donec sit amet nisl. Aliquam semper ipsum
    sit amet velit.

2.  Suspendisse id sem consectetuer libero luctus adipiscing.
""", """
<ol>
<li><p>This is a list item with two paragraphs. Lorem ipsum dolor
sit amet, consectetuer adipiscing elit. Aliquam hendrerit
mi posuere lectus.</p>

<p>Vestibulum enim wisi, viverra nec, fringilla in, laoreet
vitae, risus. Donec sit amet nisl. Aliquam semper ipsum
sit amet velit.</p></li>
<li><p>Suspendisse id sem consectetuer libero luctus adipiscing.</p></li>
</ol>
"""), # ---

    ("""
*   This is a list item with two paragraphs.

    This is the second paragraph in the list item. You're
only required to indent the first line. Lorem ipsum dolor
sit amet, consectetuer adipiscing elit.

*   Another item in the same list.
""", """
<ul>
<li><p>This is a list item with two paragraphs.</p>

<p>This is the second paragraph in the list item. You&#39;re
only required to indent the first line. Lorem ipsum dolor
sit amet, consectetuer adipiscing elit.</p></li>
<li><p>Another item in the same list.</p></li>
</ul>
"""), # ---

    ("""
*   A list item with a blockquote:

    > This is a blockquote
    > inside a list item.
""", """
<ul>
<li><p>A list item with a blockquote:</p>

<blockquote>
<p>This is a blockquote
inside a list item.</p>
</blockquote></li>
</ul>
"""), # ---

    ("""
*   A list item with a code block:

        <code goes here>
""", """
<ul>
<li><p>A list item with a code block:</p>

<pre><code>&lt;code goes here&gt;
</code></pre></li>
</ul>
"""), # ---

    ("""
1986. What a great season.

1986\. What a great season.
""", """
<ol>
<li>What a great season.</li>
</ol>

<p>1986. What a great season.</p>
"""), # ---

    ("", "\n### Code blocks\nprecode"),

    ("""
This is a normal paragraph:

    This is a code block.
""", """
<p>This is a normal paragraph:</p>

<pre><code>This is a code block.
</code></pre>
"""), # ---

    ("""
Here is an example of AppleScript:

    tell application "Foo"
        beep
    end tell
""", """
<p>Here is an example of AppleScript:</p>

<pre><code>tell application &quot;Foo&quot;
    beep
end tell
</code></pre>
"""), # ---

    ("""
    <div class="footer">
        &copy; 2004 Foo Corporation
    </div>
""", """
<pre><code>&lt;div class=&quot;footer&quot;&gt;
    &amp;copy; 2004 Foo Corporation
&lt;/div&gt;
</code></pre>
"""), # ---

    ("", "\n### Horizontal rules\nhr"),

    ("""
* * *

***

*****

- - -

---------------------------------------
""", """
<hr>

<hr>

<hr>

<hr>

<hr>
"""), # ---

    ("", "## Span Elements"),
    ("", "\n### Links\nlink"),

    ("""
This is [an example](http://example.com/ "Title") inline link.

[This link](http://example.net/) has no title attribute.

See my [About](/about/) page for details.

This is [an example][id] reference-style link.

This is [an example] [id] reference-style link.

[id]: http://example.com/  "Optional Title Here"
""", """
<p>This is <a href="http://example.com/" title="Title">an example</a> inline link.</p>

<p><a href="http://example.net/">This link</a> has no title attribute.</p>

<p>See my <a href="/about/">About</a> page for details.</p>

<p>This is <a href="http://example.com/" title="Optional Title Here">an example</a> reference-style link.</p>

<p>This is <a href="http://example.com/" title="Optional Title Here">an example</a> reference-style link.</p>
"""), # ---

    ("""
This is [an example] [id] reference-style link.

[id]: http://example.com/  'Optional Title Here'
""", """
<p>This is <a href="http://example.com/" title="Optional Title Here">an example</a> reference-style link.</p>
"""), # ---

    ("""
This is [an example] [id] reference-style link.

[id]: http://example.com/  (Optional Title Here)
""", """
<p>This is <a href="http://example.com/" title="Optional Title Here">an example</a> reference-style link.</p>
"""), # ---

    ("""
This is [an example] [id] reference-style link.

[id]: <http://example.com/>  (Optional Title Here)
""", """
<p>This is <a href="http://example.com/" title="Optional Title Here">an example</a> reference-style link.</p>
"""), # ---

    ("""
This is [an example] [id] reference-style link.
This is [an example] [ID] reference-style link.

[id]: http://example.com/longish/path/to/resource/here
    "Optional Title Here"
""", """
<p>This is <a href="http://example.com/longish/path/to/resource/here" title="Optional Title Here">an example</a> reference-style link.
This is <a href="http://example.com/longish/path/to/resource/here" title="Optional Title Here">an example</a> reference-style link.</p>
"""), # ---

    ("""
[Google][]

[Google]: http://google.com/

Visit [Daring Fireball][] for more information.

[Daring Fireball]: http://daringfireball.net/
""", """
<p><a href="http://google.com/">Google</a></p>

<p>Visit <a href="http://daringfireball.net/">Daring Fireball</a> for more information.</p>
"""), # ---

    ("""
I get 10 times more traffic from [Google] [1] than from
[Yahoo] [2] or [MSN] [3].

  [1]: http://google.com/        "Google"
  [2]: http://search.yahoo.com/  "Yahoo Search"
  [3]: http://search.msn.com/    "MSN Search"
""", """
<p>I get 10 times more traffic from <a href="http://google.com/" title="Google">Google</a> than from
<a href="http://search.yahoo.com/" title="Yahoo Search">Yahoo</a> or <a href="http://search.msn.com/" title="MSN Search">MSN</a>.</p>
"""), # ---

    ("""
I get 10 times more traffic from [Google][] than from
[Yahoo][] or [MSN][].

  [google]: http://google.com/        "Google"
  [yahoo]:  http://search.yahoo.com/  "Yahoo Search"
  [msn]:    http://search.msn.com/    "MSN Search"
""", """
<p>I get 10 times more traffic from <a href="http://google.com/" title="Google">Google</a> than from
<a href="http://search.yahoo.com/" title="Yahoo Search">Yahoo</a> or <a href="http://search.msn.com/" title="MSN Search">MSN</a>.</p>
"""), # ---

    ("""
I get 10 times more traffic from [Google](http://google.com/ "Google")
than from [Yahoo](http://search.yahoo.com/ "Yahoo Search") or
[MSN](http://search.msn.com/ "MSN Search").
""", """
<p>I get 10 times more traffic from <a href="http://google.com/" title="Google">Google</a>
than from <a href="http://search.yahoo.com/" title="Yahoo Search">Yahoo</a> or
<a href="http://search.msn.com/" title="MSN Search">MSN</a>.</p>
"""), # ---

    ("", "\n### Emphasis\nem"),

    ("""
*single asterisks*

_single underscores_

**double asterisks**

__double underscores__

un*frigging*believable

\*this text is surrounded by literal asterisks\*
""", """
<p><em>single asterisks</em></p>

<p><em>single underscores</em></p>

<p><strong>double asterisks</strong></p>

<p><strong>double underscores</strong></p>

<p>un<em>frigging</em>believable</p>

<p>*this text is surrounded by literal asterisks*</p>
"""), # ---

    ("", "\n### Code\ncode"),

    ("""
Use the `printf()` function.

``There is a literal backtick (`) here.``
""", """
<p>Use the <code>printf()</code> function.</p>

<p><code>There is a literal backtick (`) here.</code></p>
"""), # ---

    ("""
A single backtick in a code span: `` ` ``

A backtick-delimited string in a code span: `` `foo` ``
""", """
<p>A single backtick in a code span: <code>`</code></p>

<p>A backtick-delimited string in a code span: <code>`foo`</code></p>
"""), # ---

    ("""
Please don't use any `<blink>` tags.

`&#8212;` is the decimal-encoded equivalent of `&mdash;`.
""", """
<p>Please don&#39;t use any <code>&lt;blink&gt;</code> tags.</p>

<p><code>&amp;#8212;</code> is the decimal-encoded equivalent of <code>&amp;mdash;</code>.</p>
"""), # ---

    ("", "\n### Images\nimg"),

    ("""
![Alt text](/path/to/img.jpg)

![Alt text](/path/to/img.jpg "Optional title")

![Alt text][id]

[id]: url/to/image  "Optional title attribute"
""", """
<p><img src="/path/to/img.jpg" alt="Alt text"></p>

<p><img src="/path/to/img.jpg" alt="Alt text" title="Optional title"></p>

<p><img src="url/to/image" alt="Alt text" title="Optional title attribute"></p>
"""), # ---

    ("", "## Miscellaneous"),
    ("", "\n### Automatic links\nautolink"),

    ("""
http://example.com/

<http://example.com/>

<address@example.com>
""", """
<p>http://example.com/</p>

<p><a href="http://example.com/">http://example.com/</a></p>

<p><a href="mailto:address@example.com">address@example.com</a></p>
"""), # ---

    ("", "\n### Backslash escapes\nbackslash"),

    ("""
\*literal asterisks\*
""", """
<p>*literal asterisks*</p>
"""), # ---

    ] # End of base tests.

  ext_test_strings* = [
    ("""Is http://www.google.es/ a text or a link?""",
      """
<p>Is http://www.google.es/ a text or a link?</p>
""", """
<p>Is <a href="http://www.google.es/">http://www.google.es/</a> a text or a link?</p>
""", md_render_flags({}), md_ext_flags({md_ext_autolink})), # ---

    ("""
*   A list item with a code block:

        <code goes here>
""", """
<ul>
<li><p>A list item with a code block:</p>

<pre><code>&lt;code goes here&gt;
</code></pre></li>
</ul>
""", """
<ul>
<li><p>A list item with a code block:</p>

<p><code goes here></p></li>
</ul>
""", md_render_flags({}), md_ext_flags({md_ext_disable_indented_code})), # ---

    ("""
This is an ```inline triple block``` thingy. Next:

```
10 PRINT "AWESOME"
20 GOTO 10
```

Try specifying the name of the syntax:

```basic
10 PRINT "AWESOME"
20 GOTO 10
```

This `````codespan ``must`` be closed `by` exactly five backticks. `````
""", """
<p>This is an <code>inline triple block</code> thingy. Next:</p>

<p><code>
10 PRINT &quot;AWESOME&quot;
20 GOTO 10
</code></p>

<p>Try specifying the name of the syntax:</p>

<p><code>basic
10 PRINT &quot;AWESOME&quot;
20 GOTO 10
</code></p>

<p>This <code>codespan ``must`` be closed `by` exactly five backticks.</code></p>
""", """
<p>This is an <code>inline triple block</code> thingy. Next:</p>

<pre><code>10 PRINT &quot;AWESOME&quot;
20 GOTO 10
</code></pre>

<p>Try specifying the name of the syntax:</p>

<pre><code class="language-basic">10 PRINT &quot;AWESOME&quot;
20 GOTO 10
</code></pre>

<p>This <code>codespan ``must`` be closed `by` exactly five backticks.</code></p>
""", md_render_flags({}), md_ext_flags({md_ext_fenced_code})), # ---

    ("""
That's some text with a footnote.[^1]

[^1]: And that's the footnote.
""", # Examples from https://michelf.ca/projects/php-markdown/extra/#footnotes
"""
<p>That&#39;s some text with a footnote.[^1]</p>

<p>[^1]: And that&#39;s the footnote.</p>
""", """
<p>That&#39;s some text with a footnote.<sup id="fnref1"><a href="#fn1" rel="footnote">1</a></sup></p>

<div class="footnotes">
<hr>
<ol>

<li id="fn1">
<p>And that&#39;s the footnote.&nbsp;<a href="#fnref1" rev="footnote">&#8617;</a></p>
</li>

</ol>
</div>
""", md_render_flags({}), md_ext_flags({md_ext_footnotes})), # ---

    ("""
That's some text with a footnote.[^1]

[^1]: And that's the footnote.

    That's the second paragraph.
""", # Examples from https://michelf.ca/projects/php-markdown/extra/#footnotes
"""
<p>That&#39;s some text with a footnote.[^1]</p>

<p>[^1]: And that&#39;s the footnote.</p>

<pre><code>That&#39;s the second paragraph.
</code></pre>
""", """
<p>That&#39;s some text with a footnote.<sup id="fnref1"><a href="#fn1" rel="footnote">1</a></sup></p>

<div class="footnotes">
<hr>
<ol>

<li id="fn1">
<p>And that&#39;s the footnote.&nbsp;<a href="#fnref1" rev="footnote">&#8617;</a></p>

<p>That&#39;s the second paragraph.</p>
</li>

</ol>
</div>
""", md_render_flags({}), md_ext_flags({md_ext_footnotes})), # ---

    ("""
That's some text with a footnote.[^1]

[^1]:
    And that's the footnote.

    That's the second paragraph.
""", # Examples from https://michelf.ca/projects/php-markdown/extra/#footnotes
"""
<p>That&#39;s some text with a footnote.[^1]</p>

<p>[^1]:
    And that&#39;s the footnote.</p>

<pre><code>That&#39;s the second paragraph.
</code></pre>
""", """
<p>That&#39;s some text with a footnote.<sup id="fnref1"><a href="#fn1" rel="footnote">1</a></sup></p>

<div class="footnotes">
<hr>
<ol>

<li id="fn1">
<p>And that&#39;s the footnote.&nbsp;<a href="#fnref1" rev="footnote">&#8617;</a></p>

<p>That&#39;s the second paragraph.</p>
</li>

</ol>
</div>
""", md_render_flags({}), md_ext_flags({md_ext_footnotes})), # ---

    ("This is a ==highlight== and ===this too===.",
      "<p>This is a ==highlight== and ===this too===.</p>\n",
      "<p>This is a <mark>highlight</mark> and =<mark>this too</mark>=.</p>\n",
      md_render_flags({}), md_ext_flags({md_ext_highlight})), # ---

    ("""
This is a regular paragraph.
<table>
    <tr>
        <td>Foo</td>
    </tr>
</table>
""", """
<p>This is a regular paragraph.
<table>
    <tr>
        <td>Foo</td>
    </tr>
</table></p>
""", """
<p>This is a regular paragraph.</p>

<table>
    <tr>
        <td>Foo</td>
    </tr>
</table>
""", md_render_flags({}), md_ext_flags({md_ext_lax_spacing})), # ---

    ("""
The argument_parser and midnight_dynamite modules are awesome.
""", """
<p>The argument<em>parser and midnight</em>dynamite modules are awesome.</p>
""", """
<p>The argument_parser and midnight_dynamite modules are awesome.</p>
""", md_render_flags({}), md_ext_flags({md_ext_no_intra_emphasis})), # ---

    ("""Use "double quotes" or 'single quotes'.""",
"""
<p>Use &quot;double quotes&quot; or &#39;single quotes&#39;.</p>
""", """
<p>Use <q>double quotes</q> or &#39;single quotes&#39;.</p>
""", md_render_flags({}), md_ext_flags({md_ext_quote})), # ---

    ("""
# This is a header

#This is not!
""", """
<h1>This is a header</h1>

<h1>This is not!</h1>
""", """
<h1>This is a header</h1>

<p>#This is not!</p>
""", md_render_flags({}), md_ext_flags({md_ext_space_headers})), # ---

    ("""
Use ~~striked~~ text.
Extra ~~~striked~~~ text.
""", """
<p>Use ~~striked~~ text.
Extra ~~~striked~~~ text.</p>
""", """
<p>Use <del>striked</del> text.
Extra ~<del>striked</del>~ text.</p>
""", md_render_flags({}), md_ext_flags({md_ext_strikethrough})), # ---

    ("y = x^2 + 3", "<p>y = x^2 + 3</p>\n", "<p>y = x<sup>2</sup> + 3</p>\n",
      md_render_flags({}), md_ext_flags({md_ext_superscript})), # ---

    ("""
The argument_parser and midnight_dynamite modules are awesome.
""", """
<p>The argument<em>parser and midnight</em>dynamite modules are awesome.</p>
""", """
<p>The argument<u>parser and midnight</u>dynamite modules are awesome.</p>
""", md_render_flags({}), md_ext_flags({md_ext_underline})), # ---

    ("""
First Header  | Second Header
------------- | -------------
Content Cell  | Content Cell
Content Cell  | Content Cell
""", # Examples from https://michelf.ca/projects/php-markdown/extra/#table
"""
<p>First Header  | Second Header
------------- | -------------
Content Cell  | Content Cell
Content Cell  | Content Cell</p>
""", """
<table><thead>
<tr>
<th>First Header</th>
<th>Second Header</th>
</tr>
</thead><tbody>
<tr>
<td>Content Cell</td>
<td>Content Cell</td>
</tr>
<tr>
<td>Content Cell</td>
<td>Content Cell</td>
</tr>
</tbody></table>
""", md_render_flags({}), md_ext_flags({md_ext_tables})), # ---

    ("""
| First Header  | Second Header |
| ------------- | ------------- |
| Content Cell  | Content Cell  |
| Content Cell  | Content Cell  |
""", # Examples from https://michelf.ca/projects/php-markdown/extra/#table
"""
<p>| First Header  | Second Header |
| ------------- | ------------- |
| Content Cell  | Content Cell  |
| Content Cell  | Content Cell  |</p>
""", """
<table><thead>
<tr>
<th>First Header</th>
<th>Second Header</th>
</tr>
</thead><tbody>
<tr>
<td>Content Cell</td>
<td>Content Cell</td>
</tr>
<tr>
<td>Content Cell</td>
<td>Content Cell</td>
</tr>
</tbody></table>
""", md_render_flags({}), md_ext_flags({md_ext_tables})), # ---

    ("""
| Item      | Value | Buy |
|:---------:|------:|:----|
| Computer  | $1600 | No  |
| Phone     |   $12 | Yes |
| Pipe      |    $1 | No  |
""", # Examples from https://michelf.ca/projects/php-markdown/extra/#table
"""
<p>| Item      | Value | Buy |
|:---------:|------:|:----|
| Computer  | $1600 | No  |
| Phone     |   $12 | Yes |
| Pipe      |    $1 | No  |</p>
""", """
<table><thead>
<tr>
<th style="text-align: center">Item</th>
<th style="text-align: right">Value</th>
<th style="text-align: left">Buy</th>
</tr>
</thead><tbody>
<tr>
<td style="text-align: center">Computer</td>
<td style="text-align: right">$1600</td>
<td style="text-align: left">No</td>
</tr>
<tr>
<td style="text-align: center">Phone</td>
<td style="text-align: right">$12</td>
<td style="text-align: left">Yes</td>
</tr>
<tr>
<td style="text-align: center">Pipe</td>
<td style="text-align: right">$1</td>
<td style="text-align: left">No</td>
</tr>
</tbody></table>
""", md_render_flags({}), md_ext_flags({md_ext_tables})), # ---

    ("""
| One       | line | table |
|-----------|------|-------|
""", # Examples from https://michelf.ca/projects/php-markdown/extra/#table
"""
<p>| One       | line | table |
|-----------|------|-------|</p>
""", """
<table><thead>
<tr>
<th>One</th>
<th>line</th>
<th>table</th>
</tr>
</thead><tbody>
</tbody></table>
""", md_render_flags({}), md_ext_flags({md_ext_tables})), # ---
    ] # End of extension tests.
