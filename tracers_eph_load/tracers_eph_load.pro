;+
; :Description:
;   Procedure: TRACERS_EPH_LOAD
;   Purpose: Load TRACERS ephemeris data to local machine
;
; :Keywords:
;   data_filenames: bidirectional, optional, any
;     Placeholder docs for argument, keyword, or property
;   downloadonly: in, optional, any
;     if set, will only load in data - not create tplot variables
;   local_path: in, optional, str
;     Directory path on your local device where downloaded files will be saved
;   remote_path: in, optional, str
;     Directory path for Ephemeris files (default 'https://tracers-portal.physics.uiowa.edu/teams')
;   revision: in, optional, str
;     data version number to put in file (defaults to most recent)
;   trange: in, optional, str or double arr
;     load data for all files within a given range (one day granularity,
;     supercedes file list, if not set then 'timerange' will be called)
;   url_password: in, optional, str
;     password (case-sensitive) to get into the TRACERS user portal
;   url_username: in, optional, str
;     username (case-sensitive) to get into the TRACERS user portal
;   version: in, optional, str
;     software version number to put in file (defaults to most recent)
;   datatype: in, optional, str arr
;     ['eac', 'edc', 'edc-bor', 'edc-roi', 'ehf', 'hsk', 'vdc-bor', 'vdc-roi']
;     datatype handle for file (defaults to all datatypes)
;   instrument: in, optional, Array<String>
;     'efi'
;     instrument handle to put into file ('efi')
;   level: in, optional, str
;     ['l2','l1a', 'l1b']
;     level of data to put into file (defaults to l2)
;   no_server: in, optional, Boolean
;     if set, will not go looking for files remotely (not operational yet!!)
;   spacecraft: in, optional, Array<String>
;     ['ts1','ts2']
;     spacecraft handle to put in file (defaults to 'ts2')
;
; :Note to friends!:
;   Change the undefined local path variable to whereever you want to place your TRACERS data!
;
; :Future plans:
;   - update datatypes to load in a given called datatype, currently loads all
;   - update tplot section to make tplot work
;     - input files keyword to specify if full filename is given or just dates
;
; :Examples:
;
;   timespan, '2025-09-26', 1 ; one day of data
;
; :Created by:
;   Sky Shaver    Jan 2026
;
;-
pro tracers_eph_load, remote_path = remote_path, local_path = local_path, $
  downloadonly = downloadonly, trange = trange, $
  url_username = url_username, url_password = url_password, $
  version = version, revision = revision, $
  data_filenames = data_filenames
  compile_opt idl2

  if undefined(local_path) then local_path = '/Volumes/wvushaverhd/TRACERS_data' ; where to save your downloaded data
  if undefined(remote_path) then remote_path = 'https://tracers-portal.physics.uiowa.edu/teams'
  if keyword_set(downloadonly) then tplot = 0 else tplot = 1 ; if you want to only download the data, not tplot
  if undefined(version) then version = '**' ; default to latest
  if undefined(revision) then revision = '**' ; default to latest

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
    end
  end

  if undefined(trange) then trange = timerange() else trange = time_double(trange)

  days = ceil((trange[1] - trange[0]) / (24. * 3600))
  t0 = time_double(strmid(time_string(trange[0]), 0, 10))
  dates = time_string(t0 + indgen(days) * 24.d * 3600, format = 6) ; YYYYMMDDHHMMSS
  dates = strmid(dates, 0, 8) ; YYYYMMDD
  ndates = n_elements(dates)

  data_filenames = []

  for i = 0, ndates - 1 do begin
    print, '...'
    ; print, 'Reading File for Date: ', dates[i]
    print, 'Fetching File for Date: ', dates[i]
    print, '...'

    yyyy = strmid(dates[i], 0, 4)
    mm = strmid(dates[i], 4, 2)
    dd = strmid(dates[i], 6, 2)

    sw_path = '/flight/SOC/ancillary/solarwind/'
    fn_i = sw_path + 'swpc_sw_' + dates[i] + '_v' + version + '.cdf'
    dnld_paths = spd_download(remote_path = remote_path, remote_file = fn_i, local_path = local_path, $
      url_username = url_username, url_password = url_password)

    ; if user specifies, then return filenames of where the data has been saved to back to the user
    if keyword_set(data_filenames) then data_filenames = [datafilenames, dnld_paths]

    if tplot then begin
      tracers_sw_tplot, dnld_paths
    end ; tplot solar wind data
  endfor ; dates
end
