# TRACERS IDL Load Routines

IDL load routines for the TRACERS mission, designed to follow SPEDAS
conventions for data download and loading.

## Features
- Automatic data download
- Configurable local data directories
- Support for multiple data products and levels
- SPEDAS-compatible naming

## Requirements
- IDL 


## Basic Usage
```idl
tracers_load, trange=['2025-01-01','2025-01-02'], datatype='efield'