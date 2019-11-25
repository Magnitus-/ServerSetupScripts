import os
import click
import shutil

from .configs import (
    get_masters_count,
    get_inventory_destination,
    get_cluster_ips
)
from .utils import (
    run_shell_cmd,
)

def copy_sample_inventory(target):
    if not os.path.exists(target):
        shutil.copytree('/opt/kubespray/inventory/sample', target)

@click.command()
@click.option('-i', '--ips-list', multiple=True, default= lambda: get_cluster_ips())
@click.option('-m', '--masters-count', default=lambda: get_masters_count())
@click.option('-c', '--config-file', default=lambda: "{path}/hosts.yml".format(path=get_inventory_destination()))
def generate_inventory(ips_list, masters_count, config_file):
    """
    Command used to generate inventory file. It wraps the contrib/inventory_builder/inventory.py script
    of kubespray.
    """
    ips_list = " ".join(ips_list)
    copy_sample_inventory(os.path.dirname(config_file))
    run_shell_cmd(
        cmd="python3 contrib/inventory_builder/inventory.py {ips}".format(ips=ips_list),
        env={
            "CONFIG_FILE": config_file,
            "KUBE_MASTERS_MASTERS": masters_count
        }
    )