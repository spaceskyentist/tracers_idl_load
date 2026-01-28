compile_opt idl2
@'qualcolors' ; you have the qualcolors library available

device, true = 24, decompose = 0, retain = 2
loadcv, 39 ; load rainbow+white color table

; initialize for TRACERS (team only)
tracers_init

; download the data
timespan, '2025-09-26', 1 ; one day of data
tracers_sw_load, local_path = '/Volumes/wvushaverhd/TRACERS_data/' ; load solar wind data

tracers_sw_load, data_filenames = fns_sw, /downloadonly ; returns the full path and filenames of the downloaded
; data files for the given time span, doesnt create tplot variables
tracers_sw_tplot, fns_sw ; creates tplot variables from the downloaded data files
