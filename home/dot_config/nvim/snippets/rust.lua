local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

return {
    -- pub fn name(args) -> ReturnType { body }
    s(
        "pubfn",
        fmt(
            [[
pub fn {}({}) -> {} {{
    {}
}}
]],
            { i(1, "name"), i(2), i(3, "()"), i(0, "todo!()") }
        )
    ),

    -- async fn name(args) -> ReturnType { body }
    s(
        "asyncfn",
        fmt(
            [[
async fn {}({}) -> {} {{
    {}
}}
]],
            { i(1, "name"), i(2), i(3, "()"), i(0) }
        )
    ),

    -- fn name(args) -> ReturnType { body }
    s(
        "fn",
        fmt(
            [[
fn {}({}) -> {} {{
    {}
}}
]],
            { i(1, "name"), i(2), i(3, "()"), i(0, "todo!()") }
        )
    ),

    -- fn main() -> Result<()> { body; Ok(()) }
    s(
        "main",
        fmt(
            [[
fn main() -> Result<()> {{
    {}
    Ok(())
}}
]],
            { i(0) }
        )
    ),

    -- impl block for a struct or enum
    s(
        "impl",
        fmt(
            [[
impl {} {{
    {}
}}
]],
            { i(1, "Type"), i(0) }
        )
    ),

    -- struct definition with editable fields
    s(
        "struct",
        fmt(
            [[
struct {} {{
    {}: {},
}}
]],
            { i(1, "Name"), i(2, "field"), i(0, "Type") }
        )
    ),

    -- constructor inside an impl that initializes all fields
    s(
        "new",
        fmt(
            [[
pub fn new({}: {}) -> Self {{
    Self {{ {} }}
}}
]],
            { i(1, "field"), i(2, "Type"), rep(1) }
        )
    ),

    -- common derives
    s("derive", fmt("#[derive({})]", { i(1, "Debug, Clone, PartialEq, Eq, Default") })),

    -- match expression with a few placeholder arms
    s(
        "match",
        fmt(
            [[
match {} {{
    {} => {},
    {} => {},
    _ => {},
}}
]],
            { i(1, "expr"), i(2, "pattern1"), i(3, "result1"), i(4, "pattern2"), i(5, "result2"), i(0, "default") }
        )
    ),

    -- if let pattern matching boilerplate
    s(
        "iflet",
        fmt(
            [[
if let {} = {} {{
    {}
}} else {{
    {}
}}
]],
            { i(1, "Some(value)"), i(2, "expr"), i(3), i(0) }
        )
    ),

    -- #[test] function with assertion placeholder
    s(
        "test",
        fmt(
            [[
#[test]
fn {}() {{
    {}
    assert_eq!({}, {});
}}
]],
            { i(1, "test_name"), i(2), i(3, "left"), i(0, "right") }
        )
    ),

    -- #[tokio::test] async test
    s(
        "tokiotest",
        fmt(
            [[
#[tokio::test]
async fn {}() {{
    {}
}}
]],
            { i(1, "test_name"), i(0) }
        )
    ),

    -- dbg!(...) with cursor inside the macro
    s("dbg", fmt("dbg!({})", { i(0) })),

    -- tracing::info! logging macro
    s("log", fmt("tracing::info!({});", { i(0) })),
}
