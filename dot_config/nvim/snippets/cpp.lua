local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

return {
    -- ReturnType name(params) { body }
    s(
        "fn",
        fmt(
            [[
{} {}({}) {{
    {}
}}
]],
            { i(1, "void"), i(2, "name"), i(3), i(0) }
        )
    ),

    -- int main() { body; return 0; }
    s(
        "main",
        fmt(
            [[
int main() {{
    {}
    return 0;
}}
]],
            { i(0) }
        )
    ),

    -- class with a public section
    s(
        "class",
        fmt(
            [[
class {} {{
public:
    {}
}};
]],
            { i(1, "Name"), i(0) }
        )
    ),

    -- struct with editable fields
    s(
        "struct",
        fmt(
            [[
struct {} {{
    {} {};
}};
]],
            { i(1, "Name"), i(2, "Type"), i(3, "field") }
        )
    ),

    -- constructor with a member-initializer list
    s(
        "new",
        fmt(
            [[
{}({} {})
    : {}({}) {{}}
]],
            { i(1, "ClassName"), i(2, "Type"), i(3, "field"), rep(3), rep(3) }
        )
    ),

    -- rule-of-five special members
    s(
        "derive",
        fmt(
            [[
{}(const {}&) = default;
{}({}&&) = default;
{}& operator=(const {}&) = default;
{}& operator=({}&&) = default;
~{}() = default;
]],
            { i(1, "ClassName"), rep(1), rep(1), rep(1), rep(1), rep(1), rep(1), rep(1), rep(1) }
        )
    ),

    -- switch statement with a couple of placeholder cases
    s(
        "switch",
        fmt(
            [[
switch ({}) {{
    case {}:
        {}
        break;
    case {}:
        {}
        break;
    default:
        {}
}}
]],
            { i(1, "expr"), i(2, "case1"), i(3), i(4, "case2"), i(5), i(0) }
        )
    ),

    -- if-with-initializer, closest analog to Rust's `if let`
    s(
        "iflet",
        fmt(
            [[
if ({} {} = {}; {}) {{
    {}
}} else {{
    {}
}}
]],
            { i(1, "auto"), i(2, "it"), i(3, "expr"), i(4, "cond"), i(5), i(0) }
        )
    ),

    -- assert-based test function
    s(
        "test",
        fmt(
            [[
void {}() {{
    {}
    assert({} == {});
}}
]],
            { i(1, "test_name"), i(2), i(3, "actual"), i(0, "expected") }
        )
    ),

    -- quick debug print, cursor on the expression
    s("dbg", fmt("std::cerr << {} << std::endl;", { i(0) })),

    -- log line
    s("log", fmt('std::cerr << "{}" << std::endl;', { i(0) })),
}
