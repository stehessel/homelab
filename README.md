# Homelab

![GitHub Workflow Status](https://img.shields.io/github/workflow/status/stehessel/homelab/Check?label=check&style=for-the-badge)

Infrastructure code to run my home lab Kubernetes cluster.

## Continuous deployment

Bootstrap `fluxcd` via

```sh
task flux:bootstrap
```

after setting the `GITHUB_USER` and `GITHUB_TOKEN` environment variables (see [.envrc](.envrc)).
