c = get_config()
app = c.InteractiveShellApp

# This can be used at any point in a config file to load a sub config
# and merge it into the current one.
load_subconfig('ipython_config.py', profile='default')

c.TerminalIPythonApp.display_banner = False

c.InteractiveShellApp.extensions = [
    'powerline.bindings.ipython.post_0_11'
]

c.InteractiveShell.separate_in = ''
c.InteractiveShell.separate_out = ''
c.InteractiveShell.separate_out2 = ''

c.InteractiveShell.confirm_exit = False
c.InteractiveShell.deep_reload = True

c.AliasManager.user_aliases = [
    ('hgit', 'git --git-dir=$HOME/.dotfiles --work-tree=$HOME'),
]

c.PrefilterManager.multi_line_specials = True

lines = """
%rehashx
"""

app.exec_lines.append(lines)
