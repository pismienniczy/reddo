;skrypt do hurtowej ekstrakcji TM z folderów plu
;kroki do wykonania:
;-- funkcja kopiująca plik ze ścieżki (zawierającej zmienną) NIEMA
;-- pętla z powyższej funkcji dla zbiorów danych NIEMA
;-- klejenie TM-ek w folderze docelowym NIEMA
;-- nakarmienie funkcji danymi (zmiennymi do ścieżki) NIEMA

#SingleInstance force
^\::
;FormatTime, CurrentDateTime,, dd-MM-yy HH:mm
;lista zmiennych
sourcepath :=("C:\Users\Właściciel\Documents\AutoHotKey\Do_testowania_skryptów\CopyFrom\")
projectno :="O-00001"
;fullfilename :="O-00001.txt"
fullfilename = %projectno%.txt
midpath :="-TEST\To_ci_folder\"
restpath :="O-00001-TEST\To_ci_folder\"
destpath :=("C:\Users\Właściciel\Documents\AutoHotKey\Do testowania skryptów\CopyTo\")
;fullsourcepath :="C:\Users\Właściciel\Documents\AutoHotKey\Do_testowania_skryptów\CopyFrom\O-00001-TEST\To_ci_folder\"
fullsourcepath = %sourcepath%%projectno%-TEST\To_ci_folder\

;if FileExist("%sourcepath%\%projectno%-TEST\A to ci folder\%projectno%.txt")
;if FileExist "sourcepath%\*\%projectno%"
;    MsgBox, The file exists.
;else
;    MsgBox, The file does not exist.`n

;FileCopy, "%sourcepath%\%projectno%-TEST\To_ci_folder\%projectno%.txt", "%destpath%"
;FileCopy C:\Users\Właściciel\Documents\AutoHotKey\Do_testowania_skryptów\CopyFrom\O-00001-TEST\A to ci folder\O-00001.txt, C:\Users\Właściciel\Documents\AutoHotKey\Do_testowania_skryptów\
FileCopy %fullsourcepath%%fullfilename%, C:\Users\Właściciel\Documents\AutoHotKey\Do_testowania_skryptów\*.*
if ErrorLevel   ; i.e. it's not blank or zero.
	{
   MsgBox, Nie skopiowano pliku.
	}
MsgBox, %fullsourcepath%%fullfilename%
return
