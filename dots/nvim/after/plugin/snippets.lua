local ls = require('luasnip')

local s = ls.s
local i = ls.insert_node
local f = ls.function_node
local rep = require("luasnip.extras").rep
local fmt = require("luasnip.extras.fmt").fmt

-- i(1) means insert at the first position
-- i(0) means insert at the last position
ls.add_snippets("all", {
    -- Insert current datetime
    s("now", f(function()
        return os.date("%m.%d.%Y %H:%M")
    end))
})

local html_snippets = {
    s("<a>", fmt("<a href=\"{}\">{}</a>", { i(1), i(2) } ))
}

ls.add_snippets("markdown", {
    s("o", fmt("- [ ] {}", { i(1) } ))
})

ls.add_snippets("html", html_snippets);
ls.add_snippets("typescriptreact", html_snippets);

ls.add_snippets("python", {
    s("l", fmt("print(\"{}\");", { i(1) })),
    s("d", fmt("import ipdb; ipdb.set_trace()", {}))
})

ls.add_snippets("cs", {
    -- Logging
    s("l", fmt("Debug.Log(\"{}\");", { i(1) })),
    s("lv", fmt("Debug.Log(\"{}: \" + {});", { i(1), i(2) })),

    -- Function/method definitions
    s("void", fmt([[
        {} {}({}) {{
            {}
        }}
    ]], { i(1, "void"), i(2, "Function"), i(3), i(4) })),
    s("pub", fmt([[
        public {} {}({}) {{
            {}
        }}
    ]], { i(1, "void"), i(2, "Function"), i(3), i(4) })),

    -- Loops
    s("foreach", fmt([[
        foreach (var {} in {}) {{
            {}
        }}
    ]], { i(1), i(2), i(3) })),

    -- Conditionals
    s("nc", fmt([[
      if ({} == null) return;
    ]], { i(1) })),

    s("if", fmt([[
        if ({}) {{
            {}
        }}
    ]], { i(1), i(2) })),

    s("elif", fmt([[
        else if ({}) {{
            {}
        }}
    ]], { i(1), i(2) })),

    s("else", fmt([[
        else {{
            {}
        }}
    ]], { i(1) }))
})

ls.add_snippets("rust", {
    s("p", fmt("println!(\"{}\")", { i(1) })),
    s("pv", fmt("println!(\"{{}}\", {})", { i(1) })),
    s("pd", fmt("println!(\"{} {{:?}}\", {})", { i(1), i(0) })),

    s("tests", fmt([[
        #[cfg(test)]
        mod tests {{
            use super::*;

            {}
        }}
    ]], { i(0) } )),

    s("test", fmt([[
        #[test]
        fn test_{}() {{
            {}
        }}
    ]], { i(1), i(0) }))
})
