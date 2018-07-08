# Lye

Lye - a Sprockets inspired asset pipeline for Elixir / Phoenix

## Installation

The package can be installed by adding `lye` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:lye, git: "https://github.com/nicbet/elixir-lye"}
  ]
end
```

## Usage
This project is a massive WIP!

For now, you can execute the test suite with:

```sh
mix test
```

Load an asset from a load path
```elixir
env = Lye.Environment.phoenix()
Lye.Environment.load(env, "app.js")
```

## Dev Notes
Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/lye](https://hexdocs.pm/lye).

## RoadMap

#### Basic Structs
- [x] Environment
- [x] Asset
- [x] Processor

#### Functionality
- [x] Loading of assets
- [x] Caching of loaded assets
- [ ] Development mode
- [ ] Production mode
- [ ] Manifests
- [ ] Saving compiled assets to disk
- [ ] Plug / Phoenix integration

#### Processing
- [x] Default Pipeline
- [x] Basic Directive Processor
- [x] require Directive
- [ ] require_tree Directive
- [ ] require_directory Directive
- [ ] require_self Directive
- [ ] link Directive
- [ ] depend_on Directive
- [ ] depend_on_asset Directive
- [ ] stub Directive
- [ ] node_module Directive
- [ ] Custom Directives
- [x] Bundle Processor
- [ ] SCSS Processor
- [ ] Babel Processor
- [ ] CoffeeScript Processor
- [ ] Compressor
- [ ] Uglifier Processor
- [ ] Minifier Processor
- [ ] SourceMaps Processor
