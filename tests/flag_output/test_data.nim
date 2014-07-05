import midnight_dynamite

type
  Test_info* = tuple[input, output: string;
    render_flags: md_render_flags; extension_flags: md_ext_flags]

const
  test_strings*: array[2, Test_info] = [
    ("meh", "<p>meh</p>\n", md_render_flags({}), md_ext_flags({})),

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
""",
md_render_flags({}), md_ext_flags({})),
    ]
