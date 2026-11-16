local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
    -- leetcode Solution class boilerplate
    s(
        "sol",
        fmt(
            [[
from typing import List

class Solution(object):
    @staticmethod
    def {}({}) -> {}:
        {}
]],
            { i(1, "solve"), i(2, "nums: List[int]"), i(3, "int"), i(0, "pass") }
        )
    ),
}
