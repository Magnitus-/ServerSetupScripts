from setuptools import setup

setup(
    name='kubespray_commands',
    version='0.1',
    packages=['commands'],
    install_requires=[
        'click>=7',
    ],
    entry_points='''
        [console_scripts]
        kubecmds=commands:cli
    ''',
)