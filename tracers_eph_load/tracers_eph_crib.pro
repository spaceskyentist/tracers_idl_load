; initialize for TRACERS (team only)
compile_opt idl2
tracers_init
tracers_login ; set your TRACERS portal username and password

; download the data
timespan, '2025-09-26', 1 ; one day of data
tracers_eph_load, local_path = '/Volumes/wvushaverhd/TRACERS_data/', data_filenames = fns ; loads l2 data for the time span given to your specified local path on external HDD
