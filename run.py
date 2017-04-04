#!/usr/bin/env python

import winrm

ps_script = open('/mem.ps1','r').read()
s = winrm.Session('10.105.13.20', auth=('JRG.LAB\administrator', 'dbghYp9e3bR'))
r = s.run_ps(ps_script)
print r.status_code
print r.std_out
print r.std_err
