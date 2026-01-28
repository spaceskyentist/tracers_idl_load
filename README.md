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
- SPEDAS routines (e.g. `tplot`)
- IDL-colorbars routines (e.g. `loadcv`) from planetarymike [github repo here](https://github.com/planetarymike/IDL-Colorbars)


## Basic Usage
```idl
tracers_init

timespan, '2025-09-26', 1 ; one day of data

tracers_efi_load, local_path = '/Users/SkyShaver/Data/TRACERS_data/' ; loads l2 data for the time span given to your specified local path
tracers_efi_load, local_path = '/Volumes/wvushaverhd/TRACERS_data/' ; loads l2 data for the time span given to your specified local path on external HDD
tracers_efi_load, url_username = 'tracers-username', url_password = 'tracers-password' ; use these keywords if you havent set the 'TRACERS_USER_PASS' environment variable

tracers_load, trange=['2025-01-01','2025-01-02'], datatype='efield'