;+
; :Arguments:
;   filenames: bidirectional, required, any
;     Placeholder docs for argument, keyword, or property
;
;-
pro tracers_eph_tplot, filenames
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

    cdf2tplot, files = filenames, varformat = '*', tplotnames = tvars_sw, suffix = '_eph'

    stop
  endif ; over filenames found
end

; program
