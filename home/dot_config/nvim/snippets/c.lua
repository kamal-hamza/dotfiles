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

    -- int main(void) { body; return 0; }
    s(
        "main",
        fmt(
            [[
int main(void) {{
    {}
    return 0;
}}
]],
            { i(0) }
        )
    ),

    -- typedef struct with editable fields
    s(
        "struct",
        fmt(
            [[
typedef struct {{
    {} {};
}} {};
]],
            { i(2, "Type"), i(3, "field"), i(1, "Name") }
        )
    ),

    -- heap-allocating constructor: Type *Type_new(...)
    s(
        "new",
        fmt(
            [[
{} *{}_new({} {}) {{
    {} *self = malloc(sizeof({}));
    self->{} = {};
    return self;
}}
]],
            { i(1, "Type"), rep(1), rep(1), i(2, "field"), rep(1), rep(1), rep(2), rep(2) }
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

    -- assert-based test function
    s(
        "test",
        fmt(
            [[
void {}(void) {{
    {}
    assert({} == {});
}}
]],
            { i(1, "test_name"), i(2), i(3, "actual"), i(0, "expected") }
        )
    ),

    -- quick debug print, cursor on the expression
    s("dbg", fmt('fprintf(stderr, "%d\\n", {});', { i(0) })),

    -- log line
    s("log", fmt('fprintf(stderr, "{}\\n");', { i(0) })),
}
