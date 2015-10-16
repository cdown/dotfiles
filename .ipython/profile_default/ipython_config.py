c = get_config()

c.TerminalIPythonApp.extensions = [
    'autoreload',
    'line_profiler',
    'memory_profiler',
]
c.InteractiveShellApp.extensions = [
    'autoreload',
    'line_profiler',
    'memory_profiler',
]
c.InteractiveShellApp.exec_lines = ['%autoreload 2']
c.InteractiveShell.colors = 'LightBG'
c.InteractiveShell.confirm_exit = False
