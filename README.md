# Homelab

[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/stehessel/homelab/master.svg)](https://results.pre-commit.ci/latest/github/stehessel/homelab/master)

Infrastructure code to run my home lab Kubernetes cluster.

## Continuous deployment

Bootstrap `fluxcd` via

```sh
task flux:bootstrap
```

after setting the `GITHUB_USER` and `GITHUB_TOKEN` environment variables (see [.envrc](.envrc)).
