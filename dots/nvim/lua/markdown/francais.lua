--- Setup:
---
--- Install the conjugator:
---   wget 'http://perso.b2b2c.ca/~sarrazip/dev/verbiste-0.1.49.tar.gz'
---   ./configure --without-gtk-app --with-console-app
---   make && sudo make install && sudo ldconfig
---
--- Install the grammar and spellcheckers:
---   Grammalecte (https://grammalecte.net/; tested with 2.1.1)
---     wget https://grammalecte.net/zip/Grammalecte-fr-v2.1.1.zip
---   LanguageTool (https://languagetool.org/; tested with 6.5)
---     wget https://languagetool.org/download/LanguageTool-6.5.zip
---
--- Grammar checking parts based on:
---   https://github.com/dpelle/vim-LanguageTool
---   https://github.com/dpelle/vim-Grammalecte
--- but adapted to lua and nvim diagnostics.

--- Configure these paths:
local grammalecte_path = "/opt/french/grammalecte/grammalecte-cli.py"
local languagetool_path = "/opt/french/languagetool/languagetool-commandline.jar"

local ns = vim.api.nvim_create_namespace("francais")
local grammalecte_exclude_rules = [[
  apostrophe_typographique apostrophe_typographique_après_t espaces_début_ligne espaces_milieu_ligne espaces_fin_de_ligne esp_début_ligne esp_milieu_ligne esp_fin_ligne esp_mélangés2 typo_points_suspension1 typo_tiret_incise nbsp_avant_double_ponctuation nbsp_avant_deux_points nbsp_après_chevrons_ouvrants nbsp_avant_chevrons_fermants1 unit_nbsp_avant_unités1 unit_nbsp_avant_unités2 unit_nbsp_avant_unités3
]]

--- Run a system call and call the
--- callback when finished.
local function execute(command, on_output, on_err)
    local job = vim.fn.jobstart(
        command,
        {
            stdout_buffered = true,
            stderr_buffered = true,
            on_stdout = on_output,
            on_stderr = on_err,
        }
    )
end


--- Get the correct column indices.
--- It's confusing because nvim has three types of columns:
--- virtcol, charcol, and col, which either use screen position,
--- character position, or byte position (respectively).
--- For diagnostics we need the byte position,
--- but Grammalecte gives us the character position,
--- so this performs the necessary conversion.
local function charcol2bytecol(lnum, start_col, end_col)
  local line = vim.fn.getline(lnum+1)
  local s_col = vim.fn.byteidx(line, start_col - 1) + 1
  local e_col = vim.fn.byteidx(line, end_col - 1) + 1
  return {s_col, e_col}
end

--- Run Grammalecte for grammar and spellchecking.
local function run_grammalecte(path, diagnostics)
  execute({
    'python', grammalecte_path,
    '-f', path,
    '--rule_off', grammalecte_exclude_rules,
    '--json',
    '--only_when_errors',
  }, function(_, output)
    output = table.concat(output, "")
    if #output == 0 then
      return
    end
    local results = vim.json.decode(output)

    for _, para in ipairs(results['data']) do
      local line = para['iParagraph']
      local lnum = line - 1
      for _, err in ipairs(para['lGrammarErrors']) do
        local cols = charcol2bytecol(lnum, err['nStart'], err['nEnd'])
        local diagnostic = {
          lnum = lnum,
          col = cols[1],
          end_col = cols[2],
          message = '[GL] ' .. err['sMessage']
            .. '\nSuggestions: ' .. table.concat(err['aSuggestions'], ', ')
        }
        table.insert(diagnostics, diagnostic)
      end

      for _, err in ipairs(para['lSpellingErrors']) do
        local cols = charcol2bytecol(lnum, err['nStart'], err['nEnd'])
        local diagnostic = {
          lnum = lnum,
          col = cols[1],
          end_col = cols[2],
          message = "Typo: " .. err['sValue']
        }
        table.insert(diagnostics, diagnostic)
      end
    end
    vim.diagnostic.set(ns, 0, diagnostics)
  end, function(_, err)
    vim.print(err)
  end)
end

--- Run LanguageTool for grammar and spellchecking.
local function run_languagetool(path, diagnostics)
  execute({
    'java', '-jar',
    languagetool_path,
    '-c', 'utf8',
    '-d', 'WHITESPACE_RULE,EN_QUOTES', -- disable these rules
    '-m', 'en', -- English mother tongue, for faux amis detection
    '-l', 'fr',
    '--json',
    path,
  }, function(_, output)
    output = table.concat(output, "")
    if #output == 0 then
      return
    end
    local results = vim.json.decode(output)

    local text = vim.api.nvim_buf_get_lines(0, 0, -1, true)
    text = table.concat(text, "")
    for _, err in ipairs(results['matches']) do
      -- LanguageTool only gives us character offsets,
      -- so we need to convert to byte columns for vim.
      local lnum = vim.fn.byte2line(err['offset'])
      local line_start_byte = vim.fn.line2byte(lnum)
      local end_char_offset = err['offset'] + err['length']
      local start_byte_offset = vim.fn.byteidx(text, err['offset'])
      local end_byte_offset = vim.fn.byteidx(text, end_char_offset)
      local start_col = start_byte_offset - line_start_byte + 1
      local end_col = end_byte_offset - line_start_byte + 1

      -- Collect suggestions
      local suggestions =  {}
      for _, suggestion in ipairs(err['replacements']) do
        table.insert(suggestions, '"' .. suggestion['value'] .. '"')
      end

      local diagnostic = {
        lnum = lnum - 1,
        col = start_col,
        end_col = end_col,
        message = '[LT] ' .. err['message']
          .. '\nSuggestions: ' .. table.concat(suggestions, ', ')
      }
      table.insert(diagnostics, diagnostic)
    end
    vim.diagnostic.set(ns, 0, diagnostics)
  end, function(_, err)
    vim.print(err)
  end)
end

--- Display the provided lines in a floating window.
local function show_float(title, lines)
  local joined = table.concat(lines, '')
  if #joined == 0 then
    return
  end

	local buf = vim.api.nvim_create_buf(false, true)

	local opts = {
		style = "minimal",
		relative = "cursor",
		width = 48,
		height = 8,
		row = 1,
		col = 0,
    border = "single",
    title = {{" " .. title .. " ", "WinTitle"}}
	}

	local win = vim.api.nvim_open_win(buf, true, opts)
	vim.api.nvim_buf_set_option(buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.keymap.set({"n"}, "q", ":q<cr><cr>", { buffer = buf })
  vim.keymap.set({"n"}, "<esc>", ":q<cr><cr>", { buffer = buf })
  vim.api.nvim_set_option_value("filetype", "markdown", {
    buf = buf
  })
end

--- English-to-French lookup.
local function lookup_en(word)
  execute({
    'qutebrowser',
    'https://www.wordreference.com/enfr/' .. word
  }, function(_, output)
  end)
end

--- French-to-English lookup.
local function lookup_fr(word)
  execute({
    'qutebrowser',
    'https://www.wordreference.com/fren/' .. word
  }, function(_, output)
  end)
end

--- Conjugate a verb.
local function conjugate(verb)
  execute({
    'french-conjugator',
    '--pronouns', verb
  }, function(_, output)
    show_float('Conjugaison', output)
  end)
end

--- Unconjugate a verb.
local function deconjugate(verb)
  execute({
    'french-deconjugator', verb
  }, function(_, output)
    show_float('Deonjugaison', output)
  end)
end

--- Check grammar in the current buffer.
local function check_grammar()
  local text = vim.api.nvim_buf_get_lines(0, 0, -1, true)
  local temp = vim.fn.tempname()
  vim.fn.writefile(text, temp)

  local diagnostics = {}
  run_grammalecte(temp, diagnostics)
  run_languagetool(temp, diagnostics)
end

--- Autocommands
vim.api.nvim_create_autocmd({'BufRead'}, {
  pattern = '*.fr',
  callback = function(opts)
    -- Disable spellcheck
    vim.cmd([[setlocal nospell]])

    -- Chiller colors
    vim.cmd([[hi DiagnosticError guifg=#7b9fe6]])
    vim.cmd([[hi DiagnosticUnderlineError guifg=#ffaf00 gui=none]])
    vim.cmd([[hi WinTitle guifg=#000000 guibg=#ffaf87]])

    --- Keybindings
    vim.keymap.set('n', '<leader>g', function()
      -- require('telescope.builtin').diagnostics({
      --   line_width = 120,
      --   no_sign = true,
      --   path_display = 'hidden',
      --   prompt_title = 'Erreurs de Grammaire'
      -- })
    end, {buffer = opts['buffer']})
    vim.keymap.set('n', '<leader>n', function()
      local word = vim.fn.input("Word: ", "")
      lookup_en(word)
    end, {buffer = opts['buffer']})
    vim.keymap.set('n', '<leader>r', function()
      local word = vim.fn.input("Mot: ", "")
      lookup_fr(word)
    end, {buffer = opts['buffer']})
    vim.keymap.set('n', '<leader>c', function()
      local verb = vim.fn.input("Verbe: ", "")
      conjugate(verb)
    end, {buffer = opts['buffer']})
    vim.keymap.set('n', '<leader>d', function()
      local verb = vim.fn.input("Verbe: ", "")
      deconjugate(verb)
    end, {buffer = opts['buffer']})
  end
});

--- Automatically check grammar/spelling.
vim.api.nvim_create_autocmd({'BufEnter', 'BufWritePost'}, {
  pattern = '*.fr', callback = function()
    check_grammar()
  end
});
