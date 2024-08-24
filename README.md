[![tests](https://github.com/s2b/ddev-vite-sidecar/actions/workflows/tests.yml/badge.svg)](https://github.com/s2b/ddev-vite-sidecar/actions/workflows/tests.yml) ![project is maintained](https://img.shields.io/maintenance/yes/2024.svg)

# ddev-vite-sidecar <!-- omit in toc -->

ddev-vite-sidecar is an add-on for [DDEV](https://ddev.com/), a docker-based development environment. It allows
you to run the development server of the frontend tool [vite](https://vitejs.dev/) **alongside your main project**
which may use another programming language than JavaScript (such as PHP).

The vite development server runs inside DDEV's web container and is transparently exposed as a `vite.*` subdomain
to your project's main domain, which means that no ports need to be exposed to the host system.

**Contributed and maintained by [Simon Praetorius](https://github.com/s2b)**

## Get Started

Use these commands to add the add-on to your DDEV project:

```sh
ddev get s2b/ddev-vite-sidecar
ddev restart
```

During the setup process, you will be asked for your preferred frontend package manager. You can choose between
`npm`, `yarn` and `pnpm`.

## Usage

After the restart, you can use `ddev vite` to run arbitrary vite commands, such as:

```sh
# Runs the vite dev server in the foreground, which is exposed as
# "vite.your-project.ddev.site"
ddev vite

# Bundles the configured vite entrypoints
ddev vite build
```

For a reference of all available commands please check out
[vite's command line interface](https://vitejs.dev/guide/cli.html).

Please note that all commands are executed in the current working directory **on the host system**.
This means that you can also use the command if your vite config is not located in the project's root folder:

```sh
cd frontend/
ddev vite
```

## Integration

To integrate this add-on with your project's vite setup, you can use the special environment variable
`VITE_SERVER_URI` in the web container, which contains a full `https` URI to the vite dev server (e. g.
`https://vite.your-project.ddev.site`).

## Goals

The main goals of this add-on are the following:

* run a **single vite dev server** instance
* in the **foreground** (no hidden process magic)
* inside **DDEV** with the **project's dependencies** (node version, vite version...)
* without leaking **ports** to host system (by using a dedicated subdomain)
* with a simple CLI wrapper around vite's CLI
