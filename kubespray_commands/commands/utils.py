import subprocess
import os
import copy
import json

def run_shell_cmd(cmd, env=None, cwd=None):
    cwd = cwd if cwd is not None else os.getcwd()
    extended_env = os.environ
    if env is not None:
        extended_env.update(env)
    subprocess.Popen(
        cmd,
        shell=True,
        env=extended_env
    ).wait()

def ensure_dir(path):
    if not os.path.exists(path):
        os.makedirs(path)