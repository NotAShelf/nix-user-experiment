# nix-user-experiment

Experiments in hacking in support for linking files relative to user's $HOME
without relying on Home-Manager.

Goals for this experiment is to create a

- First Party
- Robust
- Customizable

interface for replacing `home.file` in Home-Manager.

## Implementation

Currently duplicates nixpkgs' users module, with the addition of a `files`
submodule - copied from the `environment.etc` module.

The theoretical framework for the implementation is:

```nix
lib.mapAttrs' (_: {name, files, home, ...}: {
  name = name;
  value.rules = lib.map (rule:
    lib.concatStringsSep " " [
      "L+"  # prepend "L+" to each string
      rule.target
      rule.mode
      rule.user
      rule.group
      rule.source
    ]
  ) (lib.filter (f: f.enable) (lib.attrValues files));
}) (lib.filterAttrs (_: u: u.files != {}) config.uses.users)
```

## Notes

This is not production ready, it will not evaluate (due to an infinite
recursion) and even if it did I would discourage you from using it.

## License

Licensed under the MIT License, following upstream Nixpkgs. See
[LICENSE](LICENSE) for more details.
