;+
;PROCEDURE: 
;	TRA_ACE_MAKE_INFO_STR
;PURPOSE: 
;	Construct an array of structures with basic information for interpreting SWIA data products
;AUTHOR: 
;	Jasper Halekas
;CALLING SEQUENCE: 
;	TRA_ACE_MAKE_INFO_STR, Info_str
;OUTPUTS: 
;	Info_str: An array of structures defining basic info for given time ranges
;
;-

pro tra_ace_make_info_str, info_str

compile_opt idl2

dt_int = 0.000900		; integration time

info_str = {valid_time_range: dblarr(2), $
energy_ave: fltarr(49), $
energy_detailed: fltarr(49,21), $
anode_angle: fltarr(21), $
cal_matrix: fltarr(49,21), $
dt_int: 0.}

info_str.valid_time_range = time_double(['2025-08-01','2030-01-01'])

info_str.dt_int = dt_int

end
