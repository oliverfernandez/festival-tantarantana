oclif-hello-world
=================

oclif example Hello World CLI

[![oclif](https://img.shields.io/badge/cli-oclif-brightgreen.svg)](https://oclif.io)
[![Version](https://img.shields.io/npm/v/oclif-hello-world.svg)](https://npmjs.org/package/oclif-hello-world)
[![CircleCI](https://circleci.com/gh/oclif/hello-world/tree/main.svg?style=shield)](https://circleci.com/gh/oclif/hello-world/tree/main)
[![Downloads/week](https://img.shields.io/npm/dw/oclif-hello-world.svg)](https://npmjs.org/package/oclif-hello-world)
[![License](https://img.shields.io/npm/l/oclif-hello-world.svg)](https://github.com/oclif/hello-world/blob/main/package.json)

<!-- toc -->
* [Usage](#usage)
* [Commands](#commands)
<!-- tocstop -->
# Usage
<!-- usage -->
```sh-session
$ npm install -g tantarantana-cli
$ tantarantana-cli COMMAND
running command...
$ tantarantana-cli (--version)
tantarantana-cli/0.0.0 darwin-x64 node-v16.17.1
$ tantarantana-cli --help [COMMAND]
USAGE
  $ tantarantana-cli COMMAND
...
```
<!-- usagestop -->
# Commands
<!-- commands -->
* [`tantarantana-cli hello PERSON`](#tantarantana-cli-hello-person)
* [`tantarantana-cli hello world`](#tantarantana-cli-hello-world)
* [`tantarantana-cli help [COMMAND]`](#tantarantana-cli-help-command)
* [`tantarantana-cli plugins`](#tantarantana-cli-plugins)
* [`tantarantana-cli plugins:install PLUGIN...`](#tantarantana-cli-pluginsinstall-plugin)
* [`tantarantana-cli plugins:inspect PLUGIN...`](#tantarantana-cli-pluginsinspect-plugin)
* [`tantarantana-cli plugins:install PLUGIN...`](#tantarantana-cli-pluginsinstall-plugin-1)
* [`tantarantana-cli plugins:link PLUGIN`](#tantarantana-cli-pluginslink-plugin)
* [`tantarantana-cli plugins:uninstall PLUGIN...`](#tantarantana-cli-pluginsuninstall-plugin)
* [`tantarantana-cli plugins:uninstall PLUGIN...`](#tantarantana-cli-pluginsuninstall-plugin-1)
* [`tantarantana-cli plugins:uninstall PLUGIN...`](#tantarantana-cli-pluginsuninstall-plugin-2)
* [`tantarantana-cli plugins update`](#tantarantana-cli-plugins-update)

## `tantarantana-cli hello PERSON`

Say hello

```
USAGE
  $ tantarantana-cli hello [PERSON] -f <value>

ARGUMENTS
  PERSON  Person to say hello to

FLAGS
  -f, --from=<value>  (required) Who is saying hello

DESCRIPTION
  Say hello

EXAMPLES
  $ oex hello friend --from oclif
  hello friend from oclif! (./src/commands/hello/index.ts)
```

_See code: [dist/commands/hello/index.ts](https://github.com/oliverfernandez/festival-tantarantana/blob/v0.0.0/dist/commands/hello/index.ts)_

## `tantarantana-cli hello world`

Say hello world

```
USAGE
  $ tantarantana-cli hello world

DESCRIPTION
  Say hello world

EXAMPLES
  $ tantarantana-cli hello world
  hello world! (./src/commands/hello/world.ts)
```

## `tantarantana-cli help [COMMAND]`

Display help for tantarantana-cli.

```
USAGE
  $ tantarantana-cli help [COMMAND] [-n]

ARGUMENTS
  COMMAND  Command to show help for.

FLAGS
  -n, --nested-commands  Include all nested commands in the output.

DESCRIPTION
  Display help for tantarantana-cli.
```

_See code: [@oclif/plugin-help](https://github.com/oclif/plugin-help/blob/v5.1.14/src/commands/help.ts)_

## `tantarantana-cli plugins`

List installed plugins.

```
USAGE
  $ tantarantana-cli plugins [--core]

FLAGS
  --core  Show core plugins.

DESCRIPTION
  List installed plugins.

EXAMPLES
  $ tantarantana-cli plugins
```

_See code: [@oclif/plugin-plugins](https://github.com/oclif/plugin-plugins/blob/v2.1.1/src/commands/plugins/index.ts)_

## `tantarantana-cli plugins:install PLUGIN...`

Installs a plugin into the CLI.

```
USAGE
  $ tantarantana-cli plugins:install PLUGIN...

ARGUMENTS
  PLUGIN  Plugin to install.

FLAGS
  -f, --force    Run yarn install with force flag.
  -h, --help     Show CLI help.
  -v, --verbose

DESCRIPTION
  Installs a plugin into the CLI.

  Can be installed from npm or a git url.

  Installation of a user-installed plugin will override a core plugin.

  e.g. If you have a core plugin that has a 'hello' command, installing a user-installed plugin with a 'hello' command
  will override the core plugin implementation. This is useful if a user needs to update core plugin functionality in
  the CLI without the need to patch and update the whole CLI.

ALIASES
  $ tantarantana-cli plugins add

EXAMPLES
  $ tantarantana-cli plugins:install myplugin 

  $ tantarantana-cli plugins:install https://github.com/someuser/someplugin

  $ tantarantana-cli plugins:install someuser/someplugin
```

## `tantarantana-cli plugins:inspect PLUGIN...`

Displays installation properties of a plugin.

```
USAGE
  $ tantarantana-cli plugins:inspect PLUGIN...

ARGUMENTS
  PLUGIN  [default: .] Plugin to inspect.

FLAGS
  -h, --help     Show CLI help.
  -v, --verbose

DESCRIPTION
  Displays installation properties of a plugin.

EXAMPLES
  $ tantarantana-cli plugins:inspect myplugin
```

## `tantarantana-cli plugins:install PLUGIN...`

Installs a plugin into the CLI.

```
USAGE
  $ tantarantana-cli plugins:install PLUGIN...

ARGUMENTS
  PLUGIN  Plugin to install.

FLAGS
  -f, --force    Run yarn install with force flag.
  -h, --help     Show CLI help.
  -v, --verbose

DESCRIPTION
  Installs a plugin into the CLI.

  Can be installed from npm or a git url.

  Installation of a user-installed plugin will override a core plugin.

  e.g. If you have a core plugin that has a 'hello' command, installing a user-installed plugin with a 'hello' command
  will override the core plugin implementation. This is useful if a user needs to update core plugin functionality in
  the CLI without the need to patch and update the whole CLI.

ALIASES
  $ tantarantana-cli plugins add

EXAMPLES
  $ tantarantana-cli plugins:install myplugin 

  $ tantarantana-cli plugins:install https://github.com/someuser/someplugin

  $ tantarantana-cli plugins:install someuser/someplugin
```

## `tantarantana-cli plugins:link PLUGIN`

Links a plugin into the CLI for development.

```
USAGE
  $ tantarantana-cli plugins:link PLUGIN

ARGUMENTS
  PATH  [default: .] path to plugin

FLAGS
  -h, --help     Show CLI help.
  -v, --verbose

DESCRIPTION
  Links a plugin into the CLI for development.

  Installation of a linked plugin will override a user-installed or core plugin.

  e.g. If you have a user-installed or core plugin that has a 'hello' command, installing a linked plugin with a 'hello'
  command will override the user-installed or core plugin implementation. This is useful for development work.

EXAMPLES
  $ tantarantana-cli plugins:link myplugin
```

## `tantarantana-cli plugins:uninstall PLUGIN...`

Removes a plugin from the CLI.

```
USAGE
  $ tantarantana-cli plugins:uninstall PLUGIN...

ARGUMENTS
  PLUGIN  plugin to uninstall

FLAGS
  -h, --help     Show CLI help.
  -v, --verbose

DESCRIPTION
  Removes a plugin from the CLI.

ALIASES
  $ tantarantana-cli plugins unlink
  $ tantarantana-cli plugins remove
```

## `tantarantana-cli plugins:uninstall PLUGIN...`

Removes a plugin from the CLI.

```
USAGE
  $ tantarantana-cli plugins:uninstall PLUGIN...

ARGUMENTS
  PLUGIN  plugin to uninstall

FLAGS
  -h, --help     Show CLI help.
  -v, --verbose

DESCRIPTION
  Removes a plugin from the CLI.

ALIASES
  $ tantarantana-cli plugins unlink
  $ tantarantana-cli plugins remove
```

## `tantarantana-cli plugins:uninstall PLUGIN...`

Removes a plugin from the CLI.

```
USAGE
  $ tantarantana-cli plugins:uninstall PLUGIN...

ARGUMENTS
  PLUGIN  plugin to uninstall

FLAGS
  -h, --help     Show CLI help.
  -v, --verbose

DESCRIPTION
  Removes a plugin from the CLI.

ALIASES
  $ tantarantana-cli plugins unlink
  $ tantarantana-cli plugins remove
```

## `tantarantana-cli plugins update`

Update installed plugins.

```
USAGE
  $ tantarantana-cli plugins update [-h] [-v]

FLAGS
  -h, --help     Show CLI help.
  -v, --verbose

DESCRIPTION
  Update installed plugins.
```
<!-- commandsstop -->
