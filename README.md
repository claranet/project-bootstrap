
# Bootstrapping Project Repositories

This project builds a docker container that is responsible for bootstrapping a
pre-configured template project into a new, ready to use, repository.


<!-- vim-markdown-toc GFM -->

* [Why?](#why)
* [User Guide](#user-guide)
    * [Requisites](#requisites)
    * [Steps](#steps)
    * [Idea](#idea)
* [Implementation](#implementation)
    * [Premises](#premises)
    * [Algorithm](#algorithm)
    * [Fanout Template Files](#fanout-template-files)
    * [Project Custom Hooks](#project-custom-hooks)

<!-- vim-markdown-toc -->

## Why?  

In order to maintain some decent degree of managability across projects we're
trying to be guided by the following ideas:

* **Principles** - Make yourself aware of how the employed technologies
  actually do work? What are their premises? These principles are applicable
  across projects.
* **Conventions** - Reuse established and proven structures, procedures,
  approaches, and ideas. Those should be rendered in code or in the directory
  hierarchy of the project repository.
* **Clear Structure** - Clearly structure the repository and hilight components,
  functional roles, their interaction.
* **Explicit Documentation** - Write documentation about the non obvious
  things, mostly how things are supposed to work. Another good example of
  necessary docs are deviations from the expected standard behaviour. Think of
  documentation as top to bottom - how is this setup/stack supposed to work. What
  are common problems? What are common tasks?
* **Implicit Documentation** via Code - If all the previous approaches do not
  provide you with the desired information, you still have the possibility to
  read the code. This requires us to render all changes in code. This demands
  further that we are writing understandable code.

In order to foster all of those points this bootstrapping mechanism and a
library of template projects are meant to help hereby.

## User Guide

### Requisites

* You need a running docker daemon locally: `docker info`
* Configured git setup: `$HOME/.gitconfig`

### Steps

1. Fork the template repository from the library
1. Clone empty repository: `git clone ...`
1. Edit values: `vim .bootstrap/input.yaml`
1. Run bootstrap: `./.bootstrap/run`

### Idea

The rationale behind this project bootstrapping mechanism is to have a library
of project templates which you could choose from as a starting point - very
much like this repo. These template repos are more a less a scaffold which gets
processed by the bootstrap mechanism. This mechanism expects a values input
file as well. These values are being consumed by the templates of this repo.

The bootstrapping mechanism could be used via the local shell wrapper script
`./.bootstrap/run`. The actual procedure is rendered as a docker container
which transparently passes through all arguments and bind mounts the local
directory as well.

## Implementation

### Premises

* Generic core logic is provided by this container; project custom stuff is
  being provided by the project templates repositories
* The expected shape of the template repo:
    * Needs to have a hidden folder called `.bootstrap/` which includes:
        * a small wrapper script to launch this container
        * an input yaml file which defines project native values which in turn
          are being consumed by the templates
        * a schema yaml file which validates the input file
    * The remainder of the template repo are seen and treated as template files
      - of course except the `.git` directory

### Algorithm

* Validate given input file against the given schema
* Create a subfolder called `.templates`
* Move over all files and directories from the top level into this `.templates`
  folder
* Process all files under this `.templates` folder as templates via `gomplate`
  and write result to top level of this repo
* Process fan out templates individually (see section below)
* Execute project template supplied hooks

### Fanout Template Files

There exist the possibility that templates evaluate to multiple effective files
depending on supplied input values. This is called fan out. Hereby the name of
the template file serves as template string by its own. Part of it will be used
to query the input values file.

The procedure as a whole is defined as the following:

* Find all templates files by the pattern `%[[:alnum:]_]*%`
* Extract this substring
* Query input yaml file for an array named this way
* For each element of the array write a separate output file (thats why it
  called fan out templates)
* Example:
    * A template file called `ansible/inventory-%environments%`
    * Query input value: `environments: [ 'prod', 'devel', 'stage' ]`
    * Effective output files:
        * `ansible/inventory-prod`
        * `ansible/inventory-devel`
        * `ansible/inventory-stage`

This is the same for directories but only one level deep. So
`ansible/inventory-%environments%/` resolves to `ansible/inventory-prod/`, but
`ansible/inventory-%environments/%other_var%/` only resolves to
`ansible/inventory-prod/%other_var%`


### Project Custom Hooks

Since we are dealing with a variety of different project types and equally we
are striving for keeping this mechanism as generic as possible this script
expects project template custom hooks.

These hooks are exepexted to be found under `.bootstrap/hooks.d/`.
