import os

c = get_config()
app = c.InteractiveShellApp

# This can be used at any point in a config file to load a sub config
# and merge it into the current one.
load_subconfig('ipython_config.py', profile='default')

c.TerminalIPythonApp.display_banner = False

c.InteractiveShellApp.extensions = [
    'powerline.bindings.ipython.post_0_11',
]

c.Powerline.path = os.environ.get('HOME') + '/.config/powerline/'

c.PromptManager.in_template = r'{color.LightGreen}\u@\h{color.LightBlue}[{color.LightCyan}\Y1{color.LightBlue}]{color.Green}|\#> '
c.PromptManager.in2_template = r'{color.Green}|{color.LightGreen}\D{color.Green}> '
c.PromptManager.out_template = r'<\#> '

c.PromptManager.justify = True

c.InteractiveShell.separate_in = ''
c.InteractiveShell.separate_out = ''
c.InteractiveShell.separate_out2 = ''

c.InteractiveShell.confirm_exit = False

c.AliasManager.user_aliases = [
    ('hgit', 'git --git-dir=$HOME/.dotfiles --work-tree=$HOME'),
]

c.PrefilterManager.multi_line_specials = True

lines = """
%rehashx
"""

app.exec_lines.append(lines)
