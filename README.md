# Signatures

![build](https://github.com/c3rb3ru5d3d53c/signatures/actions/workflows/signatures.yml/badge.svg?branch=master)
![YARA](https://img.shields.io/badge/target-yara-brightgreen)
![Suricata](https://img.shields.io/badge/target-suricata-brightgreen)
![Sigma](https://img.shields.io/badge/target-sigma-brightgreen)
[![Stars](https://img.shields.io/github/stars/c3rb3ru5d3d53c/signatures)](https://github.com/c3rb3ru5d3d53c/signatures/stargazers)
[![Forks](https://img.shields.io/github/forks/c3rb3ru5d3d53c/signatures)](https://github.com/c3rb3ru5d3d53c/signatures/network)
[![License](https://img.shields.io/github/license/c3rb3ru5d3d53c/signatures)](https://github.com/c3rb3ru5d3d53c/signatures/blob/master/LICENSE)

This repository is designed to provide a way to create and distribute detection signatures easily.

Get creative with your own detection solutions, completely unencumbered by license limitations.

To help combat evil, we firmly commit our work to the public domain for the greater good of the world. :tada:

## Downloading Compiled Signatures

- Sign-in to GitHub
- Go-to [actions](https://github.com/c3rb3ru5d3d53c/signatures/actions/)
- Download the latest build from `master` branch

## Dependencies

```bash
sudo apt update
sudo apt install make parallel docker.io jq
sudo usermod -a -G docker $USER
sudo systemctl enable docker
sudo reboot
```

## Building Signatures

- All signatures will be stored in `build/`
- Bump builds use an existing build but compile with the target version
- Multiple versions of anything can be supported!
- Use CI/CD to make it your own

### Building Suricata Signatures

```bash
make suricata-docker version=suricata-6.0.5
make suricata-docker-build version=suricata-6.0.5
```

### Building YARA Signatures

```bash
make yara-docker version=yara-4.2.0
make yara-docker-build version=yara-4.2.0
```

### Building Sigma Signatures

```bash
make sigma-docker version=sigma-0.20
make sigma-docker-build version=sigma-0.20 threads=4
```

## Packaging Signatures

To package signatures use the following.

### Package Targets

```bash
make package-targets
```

### Package All

```bash
make package
```
