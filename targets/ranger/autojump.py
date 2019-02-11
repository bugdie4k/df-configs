# https://github.com/fdw/ranger-autojump/blob/master/autojump.py

from ranger.api.commands import *
import ranger.api
import subprocess

HOOK_INIT_OLD = ranger.api.hook_init

def hook_init(fm):
    def update_autojump(signal):
        subprocess.Popen(["autojump", "--add", signal.new.path])

    fm.signal_bind('cd', update_autojump)
    HOOK_INIT_OLD(fm)


ranger.api.hook_init = hook_init

class autojump_j(Command):
    """
    :autojump_j <directory>*

    Uses autojump to set the current directory.
    """

    def execute(self):
        directory = subprocess.check_output(["autojump", self.arg(1)])
        directory = directory.decode("utf-8", "ignore")
        directory = directory.rstrip('\n')
        self.fm.execute_console("cd " + directory)
