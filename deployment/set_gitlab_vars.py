#!/usr/bin/env python
import os
import io
import gitlab
import ansible
from ansible.constants import DEFAULT_VAULT_ID_MATCH
from ansible.parsing.vault import VaultLib
from ansible.parsing.vault import VaultSecret
import click
import sys
import yaml

import logging
import contextlib
try:
    from http.client import HTTPConnection # py3
except ImportError:
    from httplib import HTTPConnection # py2

def debug_requests_on():
    '''Switches on logging of the requests module.'''
    HTTPConnection.debuglevel = 1

    logging.basicConfig()
    logging.getLogger().setLevel(logging.DEBUG)
    requests_log = logging.getLogger("requests.packages.urllib3")
    requests_log.setLevel(logging.DEBUG)
    requests_log.propagate = True

def debug_requests_off():
    '''Switches off logging of the requests module, might be some side-effects'''
    HTTPConnection.debuglevel = 0

    root_logger = logging.getLogger()
    root_logger.setLevel(logging.WARNING)
    root_logger.handlers = []
    requests_log = logging.getLogger("requests.packages.urllib3")
    requests_log.setLevel(logging.WARNING)
    requests_log.propagate = False

@contextlib.contextmanager
def debug_requests():
    '''Use with 'with'!'''
    debug_requests_on()
    yield
    debug_requests_off()

# utility functions
def gitlab_connection(server):
    try:
        global_connection
    except NameError:
        
        global_connection = gitlab.Gitlab.from_config(server, [os.path.expanduser('~/.python-gitlab.cfg')])

    return global_connection

def get_project(server,project):
  gl = gitlab_connection(server)
  gitlab_project = gl.projects.get(project)
  return gitlab_project


def set_project_variable(server,project,variable,setvalue):
  # escape the $ in $ANSIBLE_VAULT - because gitlab treats $BLAH as a variable
  if(setvalue.startswith('$')):
    setvalue = '$' + setvalue

  gitlab_project = get_project(server,project)
  try:
    setvar = gitlab_project.variables.get(variable)
    setvar_exists = True
  except gitlab.exceptions.GitlabGetError:
    setvar_exists = False

  if(setvar_exists):
    setvar.value = setvalue
    setvar.save()
    return 'updated'
  else:
    create_var_values = {}
    create_var_values['key'] = variable
    create_var_values['value'] = setvalue
    create_var_values['variable_type'] = 'file'
    gitlab_project.variables.create(create_var_values)
    return 'created'


@click.group()
def cli():
    pass

@cli.command()
@click.option('--server', default='gitlab', show_default=True)
@click.option('--project', default=None, show_default=True)
def showvariables(server,project):
    # debug_requests_on()
    gitlab_project = get_project(server,project)
    variables = gitlab_project.variables.list() 
    click.echo(f"Variable list:")
    for variable in variables:
        click.echo(f"  {variable.key} : {variable.variable_type}")

@cli.command()
@click.option('--server', default='gitlab', show_default=True)
@click.option('--project', default=None, show_default=True)
@click.option('--variable', default=None, show_default=True)
@click.option('--sourcefile', default=None, show_default=True)
def setvaultedvariable(server,project,variable,sourcefile):
    # debug_requests_on()
    if not os.path.exists(sourcefile):
      click.echo(f" Source file {sourcefile} does not exist", err=True)
      exit(1)
    sourcedata = open(sourcefile,"r").read()

    try:  
      vaultpassfile = os.environ["ANSIBLE_VAULT_PASSWORD_FILE"]
    except KeyError: 
      click.echo(f" The environment variable: ANSIBLE_VAULT_PASSWORD_FILE was not found", err=True)
      exit(1)

    if not os.path.exists(vaultpassfile):
      click.echo(f" Ansible vault password file {vaultpassfile} does not exist", err=True)
      exit(1)
    
    vaultpass = open(vaultpassfile,"r").read()
 
    vault = VaultLib([(DEFAULT_VAULT_ID_MATCH, VaultSecret(vaultpass.encode("utf-8")))])
    encrypted_sourcedata = vault.encrypt(sourcedata)
    result = set_project_variable(server,project,variable,encrypted_sourcedata.decode("utf-8"))
    click.echo(f"Variable {variable} {result} from {sourcefile}")

@cli.command()
@click.option('--server', default='gitlab', show_default=True)
@click.option('--project', default=None, show_default=True)
def setvaultpassword(server,project):
    # debug_requests_on()
    try:  
      vaultpassfile = os.environ["ANSIBLE_VAULT_PASSWORD_FILE"]
    except KeyError: 
      click.echo(f" The environment variable: ANSIBLE_VAULT_PASSWORD_FILE was not found", err=True)
      exit(1)

    if not os.path.exists(vaultpassfile):
      click.echo(f" Ansible vault password file {vaultpassfile} does not exist", err=True)
      exit(1)
    
    vaultpass = open(vaultpassfile,"r").read()
    result = set_project_variable(server,project,'ANSIBLE_VAULT_PASSWORD_FILE',vaultpass)
    click.echo(f"ANSIBLE_VAULT_PASSWORD_FILE {result}")

if __name__ == '__main__':
    cli()


    

