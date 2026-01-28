;+
; :Arguments:
;   files: bidirectional, required, any
;     Placeholder docs for argument, keyword, or property
;
; :Keywords:
;   datatype: bidirectional, optional, any
;     Placeholder docs for argument, keyword, or property
;   instrument: bidirectional, optional, any
;     Placeholder docs for argument, keyword, or property
;   level: bidirectional, optional, any
;     Placeholder docs for argument, keyword, or property
;   local_path: bidirectional, optional, any
;     Placeholder docs for argument, keyword, or property
;   no_server: bidirectional, optional, any
;     Placeholder docs for argument, keyword, or property
;   no_tplot: bidirectional, optional, any
;     Placeholder docs for argument, keyword, or property
;   remote_path: bidirectional, optional, any
;     Placeholder docs for argument, keyword, or property
;   revision: bidirectional, optional, any
;     Placeholder docs for argument, keyword, or property
;   spacecraft: bidirectional, optional, any
;     Placeholder docs for argument, keyword, or property
;   trange: bidirectional, optional, any
;     Placeholder docs for argument, keyword, or property
;   version: bidirectional, optional, any
;     Placeholder docs for argument, keyword, or property
;
;-
pro tracers_efi_load_scratchfiles, remote_path = remote_path, local_path = local_path, $
  no_tplot = no_tplot, trange = trange, no_server = no_server, $
  level = level, spacecraft = spacecraft, instrument = instrument, version = version, revision = revision, $
  datatype = datatype
  compile_opt idl2

  timespan, '2025-09-26', 1 ; only one day of data

  if undefined(local_path) then local_path = '/Volumes/wvushaverhd/TRACERS_data' ; where to save your downloaded data
  if undefined(remote_path) then remote_path = 'https://tracers-portal.physics.uiowa.edu/teams'
  if undefined(spacecraft) then spacecraft = ['ts2'] else spacecraft = strlowcase(spacecraft) ; default to ts2
  if undefined(level) then level = 'l1b' else level = strlowcase(level)
  if undefined(instrument) then instrument = 'EFI' else instrument = strupcase(instrument)
  if undefined(version) then version = '**' ; default to latest
  if undefined(revision) then revision = '**' ; default to latest
  if undefined(datatype) then dataype = 'all'
  if keyword_set(no_tplot) then tplot = 0 else tplot = 1

  nfiles = n_elements(files) ; getting the dates

  if nfiles eq 0 then begin
    trange = timerange()
    days = ceil((trange[1] - trange[0]) / (24. * 3600))
    t0 = time_double(strmid(time_string(trange[0]), 0, 10))
    dates = time_string(t0 + indgen(days) * 24.d * 3600, format = 6) ; YYYYMMDDHHMMSS
    files = strmid(dates, 0, 8) ; YYYYMMDD
    nfiles = n_elements(files)
  endif

  ; ; definining constants
  ; ; spacecraft names
  ; sc_names = 'ts1 ts2'
  ; datatype names
  d_names_l2 = 'edc-roi edc ehf vdc'
  d_names_l1a = 'eac edc-bor edc-roi ehf vdc-bor vdc-roi'
  d_names_l1b = 'eac edc-bor edc-roi ehf hsk vdc-bor vdc-roi'

  for i = 0, nfiles - 1 do begin
    print, 'Reading File for Date: ', files[i]

    yyyy = strmid(files[i], 0, 4)
    mm = strmid(files[i], 4, 2)
    dd = strmid(files[i], 6, 2)

    if level eq 'l2' then begin ; level 2 data
      instrument_path = '/flight/' + instrument + '/' + level + '/' + spacecraft + '/' + yyyy + '/' + mm + '/' + dd + '/'

      edc_fn = instrument_path + spacecraft + '_' + level + '_' + instrument + '_edc_' + mm + dd + yyyy + '_v' + version + '.cdf' ; edc
      edcroi_fn = instrument_path + spacecraft + '_' + level + '_' + instrument + '_edc-roi_' + files[i] + '_v' + version + '.cdf' ; edc
      ehf_fn = instrument_path + spacecraft + '_' + level + '_' + instrument + '_ehf_' + files[i] + '_v' + version + '.cdf' ; edc
      vdc_fn = instrument_path + spacecraft + '_' + level + '_' + instrument + '_vdc_' + files[i] + '_v' + version + '.cdf' ; edc

      dnld_paths = spd_download(remote_path = remote_path, remote_file = [edc_fn, edcroi_fn, ehf_fn, vdc_fn], local_path = local_path, $
        url_username = 'tracers-sot', url_password = 'SciOpsTeamFlight!')
    end ; loading level 2 data

    if level eq 'l1b' then begin ; loading level 1b data
      instrument_path = '/flight/SOC/' + strupcase(spacecraft) + '/' + strupcase(level) + '/' + instrument + '/' + yyyy + '/' + mm + '/' + dd + '/'

      eac_fn = instrument_path + spacecraft + '_' + level + '_' + instrument + '_eac_' + 'x**_' + files[i] + '_v' + version + '.cdf' ; eac
      edcbor_fn = instrument_path + spacecraft + '_' + level + '_' + instrument + '_edc-bor_' + 'x**_' + files[i] + '_v' + version + '.cdf' ; edc-bor
      edcroi_fn = instrument_path + spacecraft + '_' + level + '_' + instrument + '_edc-roi_' + 'x**_' + files[i] + '_v' + version + '.cdf' ; edc-roi
      ehf_fn = instrument_path + spacecraft + '_' + level + '_' + instrument + '_ehf_' + 'x**_' + files[i] + '_v' + version + '.cdf' ; ehf
      hsk_fn = instrument_path + spacecraft + '_' + level + '_' + instrument + '_hsk_' + 'x**_' + files[i] + '_v' + version + '.cdf' ; hsk
      vdcbor_fn = instrument_path + spacecraft + '_' + level + '_' + instrument + '_vdc-bor_' + 'x**_' + files[i] + '_v' + version + '.cdf' ; vdc-bor
      vdcroi_fn = instrument_path + spacecraft + '_' + level + '_' + instrument + '_vdc-roi_' + 'x**_' + files[i] + '_v' + version + '.cdf' ; vdc-roi

      dnld_paths = spd_download(remote_path = remote_path, remote_file = [eac_fn, edcbor_fn, edcroi_fn, ehf_fn, hsk_fn, vdcbor_fn, vdcroi_fn], local_path = local_path, $
        url_username = 'tracers-sot', url_password = 'SciOpsTeamFlight!')
    end ; loading level 1b data

    if tplot then begin
      ; only files that exist
      filex = file_search(dnld_paths)
      if (~is_string(filex)) then begin
        dprint, 'No files found for the time range'
        return
      end

      ; only unique files
      filex_u = filex[bsort(filex)]
      filex = filex_u[uniq(filex_u)]
      cdf2tplot, files = filex, varformat = '*', tplotnames = tvars
      if (~is_string(tnames(tvars))) then begin
        dprint, 'No Variables Loaded'
        Return
      endif

      stop

      ; check time range
      if keyword_set(trange) then begin
        if n_elements(tr) eq 2 and (tvars[0] gt '') then begin
          time_clip, tnames(tvars), trange[0], trange[1], /replace
        end
      end

      ; get_data, 'ts2_l2_edc_gei', data=dattp 'ts2_l2_edc_fac', data=dat
      ; get_data, 'ts2_l2_edc_fvc', data=dat
      ; get_data, 'ts2_l2_edc_TSCS', data=dat
      ; get_data, 'ts2_l2_edc_fitcoeff', data=dat
      ; get_data, 'ts2_l2_edc_fitcov', data=dat
      ; get_data, 'ts2_l2_edc_fitchi2', data=dat
      ; get_data, 'ts2_l2_edc_fitboundaries', data=dat
    endif ; tplot

    stop
  endfor ; over dates
end

; program

;+
; :Arguments:
;   files: bidirectional, required, any
;     Placeholder docs for argument, keyword, or property
;
; :Keywords:
;   datatype: bidirectional, optional, any
;     Placeholder docs for argument, keyword, or property
;   downloadonly: bidirectional, optional, any
;     Placeholder docs for argument, keyword, or property
;   instrument: bidirectional, optional, any
;     Placeholder docs for argument, keyword, or property
;   level: bidirectional, optional, any
;     Placeholder docs for argument, keyword, or property
;   local_path: bidirectional, optional, any
;     Placeholder docs for argument, keyword, or property
;   no_server: bidirectional, optional, any
;     Placeholder docs for argument, keyword, or property
;   remote_path: bidirectional, optional, any
;     Placeholder docs for argument, keyword, or property
;   revision: bidirectional, optional, any
;     Placeholder docs for argument, keyword, or property
;   spacecraft: bidirectional, optional, any
;     Placeholder docs for argument, keyword, or property
;   trange: bidirectional, optional, any
;     Placeholder docs for argument, keyword, or property
;   url_password: bidirectional, optional, any
;     Placeholder docs for argument, keyword, or property
;   url_username: bidirectional, optional, any
;     Placeholder docs for argument, keyword, or property
;   version: bidirectional, optional, any
;     Placeholder docs for argument, keyword, or property
;
;-
pro tracers_efi_load_scratch2, files, remote_path = remote_path, local_path = local_path, $
  downloadonly = downloadonly, trange = trange, no_server = no_server, $
  level = level, spacecraft = spacecraft, instrument = instrument, version = version, revision = revision, $
  datatype = datatype, url_username = url_username, url_password = url_password
  compile_opt idl2

  timespan, '2025-09-26', 1

  if undefined(local_path) then local_path = '/Volumes/wvushaverhd/TRACERS_data' ; where to save your downloaded data
  if undefined(remote_path) then remote_path = 'https://tracers-portal.physics.uiowa.edu/teams'
  if undefined(spacecraft) then spacecraft = ['ts2'] else spacecraft = strlowcase(spacecraft) ; default to ts2
  if undefined(level) then level = 'l2' else level = strlowcase(level)
  if undefined(instrument) then instrument = 'EFI' else instrument = strupcase(instrument)
  if undefined(version) then version = '**' ; default to latest
  if undefined(revision) then revision = '**' ; default to latest
  if undefined(datatype) then dataype = 'all'
  if keyword_set(downloadonly) then tplot = 0 else tplot = 1 ; if you want to only download the data, not tplot

  if undefined(url_username) or undefined(url_password) then begin
    check = getenv('TRACERS_USER_PASS')
    if check eq '' then begin
      print, 'Please input TRACERS url username and password as keywords'
      print, 'Returning...'
      print, ''
      return
    end else begin
      uspw = strsplit(check, ':', /extract)
      url_username = uspw[0]
      url_password = uspw[1]
      stop
    end
  end

  nfiles = n_elements(files) ; getting the dates

  if nfiles eq 0 then begin
    trange = timerange()
    days = ceil((trange[1] - trange[0]) / (24. * 3600))
    t0 = time_double(strmid(time_string(trange[0]), 0, 10))
    dates = time_string(t0 + indgen(days) * 24.d * 3600, format = 6) ; YYYYMMDDHHMMSS
    files = strmid(dates, 0, 8) ; YYYYMMDD
    nfiles = n_elements(files)
  endif

  ; ; definining constants
  ; ; spacecraft names
  ; sc_names = 'ts1 ts2'
  ; datatype names
  d_names_l2 = 'edc-roi edc ehf vdc'
  d_names_l1a = 'eac edc-bor edc-roi ehf vdc-bor vdc-roi'
  d_names_l1b = 'eac edc-bor edc-roi ehf hsk vdc-bor vdc-roi'

  for i = 0, nfiles - 1 do begin
    print, '...'
    print, 'Reading File for Date: ', files[i]
    print, '...'

    yyyy = strmid(files[i], 0, 4)
    mm = strmid(files[i], 4, 2)
    dd = strmid(files[i], 6, 2)

    if level eq 'l2' then begin ; level 2 data
      instrument_path = '/flight/' + instrument + '/' + level + '/' + spacecraft + '/' + yyyy + '/' + mm + '/' + dd + '/'

      edc_fn = instrument_path + spacecraft + '_' + level + '_' + instrument + '_edc_' + mm + dd + yyyy + '_v' + version + '.cdf' ; edc
      edcroi_fn = instrument_path + spacecraft + '_' + level + '_' + instrument + '_edc-roi_' + files[i] + '_v' + version + '.cdf' ; edc
      ehf_fn = instrument_path + spacecraft + '_' + level + '_' + instrument + '_ehf_' + files[i] + '_v' + version + '.cdf' ; edc
      vdc_fn = instrument_path + spacecraft + '_' + level + '_' + instrument + '_vdc_' + files[i] + '_v' + version + '.cdf' ; edc

      dnld_paths = spd_download(remote_path = remote_path, remote_file = [edc_fn, edcroi_fn, ehf_fn, vdc_fn], local_path = local_path, $
        url_username = url_username, url_password = url_password)
    end ; loading level 2 data

    if level eq 'l1b' then begin ; loading level 1b data
      instrument_path = '/flight/SOC/' + strupcase(spacecraft) + '/' + strupcase(level) + '/' + instrument + '/' + yyyy + '/' + mm + '/' + dd + '/'

      eac_fn = instrument_path + spacecraft + '_' + level + '_' + instrument + '_eac_' + 'x**_' + files[i] + '_v' + version + '.cdf' ; eac
      edcbor_fn = instrument_path + spacecraft + '_' + level + '_' + instrument + '_edc-bor_' + 'x**_' + files[i] + '_v' + version + '.cdf' ; edc-bor
      edcroi_fn = instrument_path + spacecraft + '_' + level + '_' + instrument + '_edc-roi_' + 'x**_' + files[i] + '_v' + version + '.cdf' ; edc-roi
      ehf_fn = instrument_path + spacecraft + '_' + level + '_' + instrument + '_ehf_' + 'x**_' + files[i] + '_v' + version + '.cdf' ; ehf
      hsk_fn = instrument_path + spacecraft + '_' + level + '_' + instrument + '_hsk_' + 'x**_' + files[i] + '_v' + version + '.cdf' ; hsk
      vdcbor_fn = instrument_path + spacecraft + '_' + level + '_' + instrument + '_vdc-bor_' + 'x**_' + files[i] + '_v' + version + '.cdf' ; vdc-bor
      vdcroi_fn = instrument_path + spacecraft + '_' + level + '_' + instrument + '_vdc-roi_' + 'x**_' + files[i] + '_v' + version + '.cdf' ; vdc-roi

      dnld_paths = spd_download(remote_path = remote_path, remote_file = [eac_fn, edcbor_fn, edcroi_fn, ehf_fn, hsk_fn, vdcbor_fn, vdcroi_fn], local_path = local_path, $
        url_username = url_username, url_password = url_password)
    end ; loading level 1b data

    if level eq 'l1a' then begin ; loading level 1b data
      instrument_path = '/flight/SOC/' + strupcase(spacecraft) + '/' + strupcase(level) + '/' + instrument + '/' + yyyy + '/' + mm + '/' + dd + '/'

      eac_fn = instrument_path + spacecraft + '_' + level + '_' + instrument + '_eac_' + 'x**_' + files[i] + '_v' + version + '.cdf' ; eac
      edcbor_fn = instrument_path + spacecraft + '_' + level + '_' + instrument + '_edc-bor_' + 'x**_' + files[i] + '_v' + version + '.cdf' ; edc-bor
      edcroi_fn = instrument_path + spacecraft + '_' + level + '_' + instrument + '_edc-roi_' + 'x**_' + files[i] + '_v' + version + '.cdf' ; edc-roi
      ehf_fn = instrument_path + spacecraft + '_' + level + '_' + instrument + '_ehf_' + 'x**_' + files[i] + '_v' + version + '.cdf' ; ehf
      hsk_fn = instrument_path + spacecraft + '_' + level + '_' + instrument + '_hsk_' + 'x**_' + files[i] + '_v' + version + '.cdf' ; hsk
      vdcbor_fn = instrument_path + spacecraft + '_' + level + '_' + instrument + '_vdc-bor_' + 'x**_' + files[i] + '_v' + version + '.cdf' ; vdc-bor
      vdcroi_fn = instrument_path + spacecraft + '_' + level + '_' + instrument + '_vdc-roi_' + 'x**_' + files[i] + '_v' + version + '.cdf' ; vdc-roi

      dnld_paths = spd_download(remote_path = remote_path, remote_file = [eac_fn, edcbor_fn, edcroi_fn, ehf_fn, hsk_fn, vdcbor_fn, vdcroi_fn], local_path = local_path, $
        url_username = url_username, url_password = url_password)
    end ; loading level 1a data

    ; ; THIS TPLOT SECTION IS STILL BEING WORKED ON! This will load the files into tplot variables,
    ; ; but the times are off!

    ; if tplot then begin
    ; ; only files that exist
    ; filex = file_search(dnld_paths)
    ; if (~is_string(filex)) then begin
    ; dprint, 'No files found for the time range'
    ; return
    ; end

    ; ; only unique files
    ; filex_u = filex[bsort(filex)]
    ; filex = filex_u[uniq(filex_u)]
    ; cdf2tplot, files = filex, varformat = '*', tplotnames = tvars
    ; if (~is_string(tnames(tvars))) then begin
    ; dprint, 'No Variables Loaded'
    ; Return
    ; endif

    ; ; check time range
    ; if keyword_set(trange) then begin
    ; if n_elements(tr) eq 2 and (tvars[0] gt '') then begin
    ; time_clip, tnames(tvars), trange[0], trange[1], /replace
    ; end
    ; end
    ; endif ; tplot
    ;
    ;
    if tplot then begin
      tracers_efi_tplot, dnld_paths, spacecraft = spacecraft, level = level

      stop
      if (size(dnld_paths, /type) eq 7) then begin
        ; only proceed if filenames are found
        filenames = dnld_paths
        finfo = file_info(filenames)
        indx = where(finfo.exists, nfilesexists, comp = jndx, ncomp = n)
        for j = 0, (n - 1) do print, 'File not found: ', file[jndx[j]]
        if (nfilesexists eq 0) then begin
          dprint, 'No files found for the time range... Returning.'
          return
        endif
        filenames = filenames[indx]

        indx = where(strmatch(filenames, '*edc_*'), nedcfiles)
        if (nedcfiles gt 0) then begin
          edcfile = filenames[indx]
          cdf2tplot, files = edcfile, varformat = '*', tplotnames = tvars_edc
        endif

        indx = where(strmatch(filenames, '*edc-roi_*'), nedcroifiles)
        if (nedcroifiles gt 0) then begin
          edcroifile = filenames[indx]
          cdf2tplot, files = edcroifile, varformat = '*', tplotnames = tvars_roi, midfix = 'edc-roi_', midpos = 'edc_'
        endif

        indx = where(strmatch(filenames, '*edc-bor_*'), nedcborfiles)
        if (nedcborfiles gt 0) then begin
          edcborfile = filenames[indx]
          cdf2tplot, files = edcborfile, varformat = '*', tplotnames = tvars_bor, midfix = 'edc-bor_', midpos = 'edc_'
        endif

        indx = where(strmatch(filenames, '*ehf_*'), nehffiles)
        if (nehffiles gt 0) then begin
          ehffile = filenames[indx]
          cdf2tplot, files = ehffile, varformat = '*', tplotnames = tvars_ehf
        endif

        indx = where(strmatch(filenames, '*vdc_*'), nvdcfiles)
        if (nvdcfiles gt 0) then begin
          vdcfile = filenames[indx]
          cdf2tplot, files = vdcfile, varformat = '*', tplotnames = tvars_vdc
        endif

        indx = where(strmatch(filenames, '*vdc-roi_*'), nvdcroifiles)
        if (nvdcroifiles gt 0) then begin
          vdcroifile = filenames[indx]
          cdf2tplot, files = vdcroifile, varformat = '*', tplotnames = tvars_roi, midfix = 'vdc-roi_', midpos = 'vdc_'
        endif

        indx = where(strmatch(filenames, '*vdc-bor_*'), nvdcborfiles)
        if (nvdcborfiles gt 0) then begin
          vdcborfile = filenames[indx]
          cdf2tplot, files = vdcborfile, varformat = '*', tplotnames = tvars_bor, midfix = 'vdc-bor_', midpos = 'vdc_'
        endif

        indx = where(strmatch(filenames, '*hsk_*'), nhskfiles)
        if (nhskfiles gt 0) then begin
          hskfile = filenames[indx]
          cdf2tplot, files = hskfile, varformat = '*', tplotnames = tvars_hsk
        endif

        indx = where(strmatch(filenames, '*eac_*'), neacfiles)
        if (neacfiles gt 0) then begin
          eacfile = filenames[indx]
          cdf2tplot, files = eacfile, varformat = '*', tplotnames = tvars_eac
        endif
      endif ; if filenames are given in string format

      stop

      ; check time range
      if keyword_set(trange) then begin
        if n_elements(tr) eq 2 and (tvars[0] gt '') then begin
          time_clip, tnames(tvars), trange[0], trange[1], /replace
        end
      end
    endif ; tplot
  endfor ; over dates/files
end
