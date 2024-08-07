# Luna & Co. DevContainer

## Usage

Use the [pre-built DevContainer image](https://containers.dev/guide/prebuild).

```json
// For format details, see https://aka.ms/devcontainer.json. For config options, see the
{
  "name": "Luna & Co.",

  "image": "ghcr.io/lunaetco/devcontainer:latest",
  "remoteUser": "vscode",
  "workspaceFolder": "/workspaces/${localWorkspaceFolderBasename}",

  // Use `forwardPorts` to make a list of ports inside the container available
  // locally. This can be used to network with other containers or the host.
  "forwardPorts": [],

  // Set environmental variables
  "containerEnv": {},

  // Configure tool-specific properties.
  "customizations": {
    "vscode": {
      "extensions": [
        "bradlc.vscode-tailwindcss",
        "dotenv.dotenv-vscode",
        "eamodio.gitlens",
        "esbenp.prettier-vscode",
        "fill-labs.dependi",
        "foxundermoon.shell-format",
        "mikestead.dotenv",
        "ms-azuretools.vscode-docker"
      ],
      "settings": {
        "editor.formatOnSave": true,
        "editor.inlineSuggest.enabled": true,
        "files.autoSave": "afterDelay",
        "prettier.prettierPath": "/usr/local/share/nvm/current/lib/node_modules/prettier",
        "shellformat.path": "/usr/bin/shfmt"
      }
    }
  }
}
```

## Building locally

Use the DevContainers CLI.

```sh
npx @devcontainers/cli build --workspace-folder . --image-name ghcr.io/lunaetco/devcontainer:latest
```
