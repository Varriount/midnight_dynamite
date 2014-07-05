import midnight_dynamite

type
  Test_info* = tuple[input, output: string;
    render_flags: md_render_flags; extension_flags: md_ext_flags]

const
  test_strings* = [
    ("meh", "<p>meh</p>\n", md_render_flags({}), md_ext_flags({})), # ---

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
""", md_render_flags({}), md_ext_flags({})), # ---

    ("http://images.google.com/images?num=30&q=larry+bird",
      "<p>http://images.google.com/images?num=30&amp;q=larry+bird</p>\n",
      md_render_flags({}), md_ext_flags({})), # ---

    ("""
<a href="http://images.google.com/images?num=30&q=larry+bird">images</a>
""", """
<p><a href="http://images.google.com/images?num=30&q=larry+bird">images</a></p>
""", md_render_flags({}), md_ext_flags({})), # ---

    ("""
<a href="http://images.google.com/images?num=30&q=larry+bird">images</a>
""", """
<p><a href="http://images.google.com/images?num=30&q=larry+bird">images</a></p>
""", md_render_flags({}), md_ext_flags({})), # ---

    ("&copy; AT&T 4 < 5", "<p>&copy; AT&amp;T 4 &lt; 5</p>\n",
      md_render_flags({}), md_ext_flags({})), # ---

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
""", md_render_flags({}), md_ext_flags({})), # ---

    ("""
This is an H1
=============

This is an H2
-------------

body""", """
<h1>This is an H1</h1>

<h2>This is an H2</h2>

<p>body</p>
""", md_render_flags({}), md_ext_flags({})), # ---


    ("""
# This is an H1

## This is an H2

###### This is an H6

body""", """
<h1>This is an H1</h1>

<h2>This is an H2</h2>

<h6>This is an H6</h6>

<p>body</p>
""", md_render_flags({}), md_ext_flags({})), # ---

    ("""
# This is an H1 #

## This is an H2 ##

### This is an H3 ######

body""", """
<h1>This is an H1</h1>

<h2>This is an H2</h2>

<h3>This is an H3</h3>

<p>body</p>
""", md_render_flags({}), md_ext_flags({})), # ---

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
""", md_render_flags({}), md_ext_flags({})), # ---

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
""", md_render_flags({}), md_ext_flags({})), # ---

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
""", md_render_flags({}), md_ext_flags({})), # ---

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
""", md_render_flags({}), md_ext_flags({})), # ---

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
""", md_render_flags({}), md_ext_flags({})), # ---

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
""", md_render_flags({}), md_ext_flags({})), # ---

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
""", md_render_flags({}), md_ext_flags({})), # ---

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
""", md_render_flags({}), md_ext_flags({})), # ---

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
""", md_render_flags({}), md_ext_flags({})), # ---

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
""", md_render_flags({}), md_ext_flags({})), # ---

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
""", md_render_flags({}), md_ext_flags({})), # ---

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
""", md_render_flags({}), md_ext_flags({})), # ---

    ("""
*   Bird

*   Magic
""", """
<ul>
<li><p>Bird</p></li>
<li><p>Magic</p></li>
</ul>
""", md_render_flags({}), md_ext_flags({})), # ---

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
""", md_render_flags({}), md_ext_flags({})), # ---

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
""", md_render_flags({}), md_ext_flags({})), # ---

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
""", md_render_flags({}), md_ext_flags({})), # ---

    ("""
*   A list item with a code block:

        <code goes here>
""", """
<ul>
<li><p>A list item with a code block:</p>

<pre><code>&lt;code goes here&gt;
</code></pre></li>
</ul>
""", md_render_flags({}), md_ext_flags({})), # ---

    ("""
1986. What a great season.

1986\. What a great season.
""", """
<ol>
<li>What a great season.</li>
</ol>

<p>1986. What a great season.</p>
""", md_render_flags({}), md_ext_flags({})), # ---

    ("""
This is a normal paragraph:

    This is a code block.
""", """
<p>This is a normal paragraph:</p>

<pre><code>This is a code block.
</code></pre>
""", md_render_flags({}), md_ext_flags({})), # ---

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
""", md_render_flags({}), md_ext_flags({})), # ---

    ("""
    <div class="footer">
        &copy; 2004 Foo Corporation
    </div>
""", """
<pre><code>&lt;div class=&quot;footer&quot;&gt;
    &amp;copy; 2004 Foo Corporation
&lt;/div&gt;
</code></pre>
""", md_render_flags({}), md_ext_flags({})), # ---

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
""", md_render_flags({}), md_ext_flags({})), # ---

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
""", md_render_flags({}), md_ext_flags({})), # ---

    ("""
This is [an example] [id] reference-style link.

[id]: http://example.com/  'Optional Title Here'
""", """
<p>This is <a href="http://example.com/" title="Optional Title Here">an example</a> reference-style link.</p>
""", md_render_flags({}), md_ext_flags({})), # ---

    ("""
This is [an example] [id] reference-style link.

[id]: http://example.com/  (Optional Title Here)
""", """
<p>This is <a href="http://example.com/" title="Optional Title Here">an example</a> reference-style link.</p>
""", md_render_flags({}), md_ext_flags({})), # ---

    ("""
This is [an example] [id] reference-style link.

[id]: <http://example.com/>  (Optional Title Here)
""", """
<p>This is <a href="http://example.com/" title="Optional Title Here">an example</a> reference-style link.</p>
""", md_render_flags({}), md_ext_flags({})), # ---

    ("""
This is [an example] [id] reference-style link.
This is [an example] [ID] reference-style link.

[id]: http://example.com/longish/path/to/resource/here
    "Optional Title Here"
""", """
<p>This is <a href="http://example.com/longish/path/to/resource/here" title="Optional Title Here">an example</a> reference-style link.
This is <a href="http://example.com/longish/path/to/resource/here" title="Optional Title Here">an example</a> reference-style link.</p>
""", md_render_flags({}), md_ext_flags({})), # ---

    ("""
[Google][]

[Google]: http://google.com/

Visit [Daring Fireball][] for more information.

[Daring Fireball]: http://daringfireball.net/
""", """
<p><a href="http://google.com/">Google</a></p>

<p>Visit <a href="http://daringfireball.net/">Daring Fireball</a> for more information.</p>
""", md_render_flags({}), md_ext_flags({})), # ---

    ("""
I get 10 times more traffic from [Google] [1] than from
[Yahoo] [2] or [MSN] [3].

  [1]: http://google.com/        "Google"
  [2]: http://search.yahoo.com/  "Yahoo Search"
  [3]: http://search.msn.com/    "MSN Search"
""", """
<p>I get 10 times more traffic from <a href="http://google.com/" title="Google">Google</a> than from
<a href="http://search.yahoo.com/" title="Yahoo Search">Yahoo</a> or <a href="http://search.msn.com/" title="MSN Search">MSN</a>.</p>
""", md_render_flags({}), md_ext_flags({})), # ---

    ("""
I get 10 times more traffic from [Google][] than from
[Yahoo][] or [MSN][].

  [google]: http://google.com/        "Google"
  [yahoo]:  http://search.yahoo.com/  "Yahoo Search"
  [msn]:    http://search.msn.com/    "MSN Search"
""", """
<p>I get 10 times more traffic from <a href="http://google.com/" title="Google">Google</a> than from
<a href="http://search.yahoo.com/" title="Yahoo Search">Yahoo</a> or <a href="http://search.msn.com/" title="MSN Search">MSN</a>.</p>
""", md_render_flags({}), md_ext_flags({})), # ---

    ("""
I get 10 times more traffic from [Google](http://google.com/ "Google")
than from [Yahoo](http://search.yahoo.com/ "Yahoo Search") or
[MSN](http://search.msn.com/ "MSN Search").
""", """
<p>I get 10 times more traffic from <a href="http://google.com/" title="Google">Google</a>
than from <a href="http://search.yahoo.com/" title="Yahoo Search">Yahoo</a> or
<a href="http://search.msn.com/" title="MSN Search">MSN</a>.</p>
""", md_render_flags({}), md_ext_flags({})), # ---

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
""", md_render_flags({}), md_ext_flags({})), # ---

    ("""
Use the `printf()` function.

``There is a literal backtick (`) here.``
""", """
<p>Use the <code>printf()</code> function.</p>

<p><code>There is a literal backtick (`) here.</code></p>
""", md_render_flags({}), md_ext_flags({})), # ---

    ("""
A single backtick in a code span: `` ` ``

A backtick-delimited string in a code span: `` `foo` ``
""", """
<p>A single backtick in a code span: <code>`</code></p>

<p>A backtick-delimited string in a code span: <code>`foo`</code></p>
""", md_render_flags({}), md_ext_flags({})), # ---

    ("""
Please don't use any `<blink>` tags.

`&#8212;` is the decimal-encoded equivalent of `&mdash;`.
""", """
<p>Please don&#39;t use any <code>&lt;blink&gt;</code> tags.</p>

<p><code>&amp;#8212;</code> is the decimal-encoded equivalent of <code>&amp;mdash;</code>.</p>
""", md_render_flags({}), md_ext_flags({})), # ---

    ("""
![Alt text](/path/to/img.jpg)

![Alt text](/path/to/img.jpg "Optional title")

![Alt text][id]

[id]: url/to/image  "Optional title attribute"
""", """
<p><img src="/path/to/img.jpg" alt="Alt text"></p>

<p><img src="/path/to/img.jpg" alt="Alt text" title="Optional title"></p>

<p><img src="url/to/image" alt="Alt text" title="Optional title attribute"></p>
""", md_render_flags({}), md_ext_flags({})), # ---

    ("""
http://example.com/

<http://example.com/>

<address@example.com>
""", """
<p>http://example.com/</p>

<p><a href="http://example.com/">http://example.com/</a></p>

<p><a href="mailto:address@example.com">address@example.com</a></p>
""", md_render_flags({}), md_ext_flags({})), # ---

    ("""
\*literal asterisks\*
""", """
<p>*literal asterisks*</p>
""", md_render_flags({}), md_ext_flags({})), # ---

    ]
