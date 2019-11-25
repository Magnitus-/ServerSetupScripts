import click

from .generate_inventory_cmd import generate_inventory

@click.group()
def cli():
    pass

cli.add_command(generate_inventory)