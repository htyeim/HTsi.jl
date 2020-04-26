#= 
RemoteFiles.@RemoteFile — Macro.
@RemoteFile name url [key=value...]
Assign the RemoteFile located at url to the variable name.

The following keyword arguments are available:

file: Set a different local file name.
dir: The download directory. If dir is not set RemoteFiles will create a new directory data under the root of the current package and save the file there.
updates (default: :never): Indicates with which frequency the remote file is updated. Possible values are:
:never
:daily
:monthly
:yearly
:mondays/:weekly, :tuesdays, etc.
retries (default: 3): How many retries should be attempted.
try_backends (default: true): Whether to retry with different backends.
wait (default: 5): How many seconds to wait between retries.
failed (default: :error): What to do if the download fails. Either throw an exception (:error) or display a warning (:warn). =#


#= 
    # There are three possible sources of data. Search for
    # them in the following order:
    # 1) Final
    # 2) Provisional
    # 3) Realtime
    year_month = '%i%02i' % (year, month)
    wgdc_fn = 'dst%s%02i.for.request' % (str(year)[2:], month)
    src_final = 'http://wdc.kugi.kyoto-u.ac.jp/dst_final/%s/%s' % \
        (year_month, wgdc_fn)
    src_provisional = \
        'http://wdc.kugi.kyoto-u.ac.jp/dst_provisional/%s/%s' % \
        (year_month, wgdc_fn)
    src_realtime = 'http://wdc.kugi.kyoto-u.ac.jp/dst_realtime/%s/%s' % \
        (year_month, wgdc_fn) =#