;+
; :Arguments:
;   filenames: bidirectional, required, str
;     path and filenames to get to cdf files to convert to tplot
;
; :Examples:
;   tracers_sw_tplot, fn
;   This command sets the tplot options for TRACERS Solar wind data
;
; :Notes:
;   This procedure assumes that the relevant TRACERS sw data has already been
;   loaded in using tracers_sw_load.
;   MODIFICATION HISTORY:
;   Written by Skylar Shaver, Jan 2026
;
;-
pro tracers_sw_tplot, filenames
  compile_opt idl2

  if (size(filenames, /type) eq 7) then begin
    ; only proceed if filenames are found
    finfo = file_info(filenames)
    indx = where(finfo.exists, nfilesexists, comp = jndx, ncomp = n)
    for j = 0, (n - 1) do print, 'File not found: ', filenames[jndx[j]]
    if (nfilesexists eq 0) then begin
      dprint, 'No files found for the time range... Returning.'
      return
    endif
    filenames = filenames[indx]

    cdf2tplot, files = filenames, varformat = '*', tplotnames = tvars_sw, suffix = '_sw'

    options, 'platform_sw', yrange = [0, 5], psym = 1
    options, 'bdc_sw', ytitle = 'B IMF !C (nT)', colors = ['r', 'g', 'b'], labflag = 1, labels = ['BX!DGSM!N', 'BY!DGSM!N', 'BZ!DGSM!N']
    options, 'proton_sp_sw', ytitle = 'Proton Speed !C (km/s) GSE'
    options, 'proton_dens_sw', ytitle = 'Proton Density !C (cm^-3) GSE'
    options, 'proton_temp_sw', ytitle = 'Horizontal Proton Temperature? !C (K)'
  endif ; over filenames found
end
