for %%G in (*.sql) do sqlcmd /S KONG /d LMS -U LoginLMS -P 123 -i"%%G"