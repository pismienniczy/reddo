;skrypt do hurtowej ekstrakcji TM z folderów plu
;kroki do wykonania:
;-- funkcja sprawdzająca, czy żądany plik istnieje (przydatne przed kopiowaniem) JAKBY JEST
;-- funkcja kopiująca plik ze ścieżki (zawierającej zmienną) JAKBY JEST
;-- pętla z powyższej funkcji dla zbiorów danych NIEMA
;-- klejenie TM-ek w folderze docelowym NIEMA
;-- nakarmienie funkcji danymi (zmiennymi do ścieżki) NIEMA

#SingleInstance force
^\::
;FormatTime, CurrentDateTime,, dd-MM-yy HH:mm
;if FileExist("%sourcepath%\%projectno%-TEST\A to ci folder\%projectno%.txt")
;if FileExist "sourcepath%\*\%projectno%"
;    MsgBox, The file exists.
;else
;    MsgBox, The file does not exist.`n

;if FileExist "C:\Users\Właściciel\Documents\AutoHotKey\Do_testowania_skryptów\CopyFrom\O-00001-TEST\To_ci_folder\O-00001.txt"

;lista zmiennych:
sourcepath :=("C:\Users\Właściciel\Documents\AutoHotKey\Do_testowania_skryptów\CopyFrom\") ;tam jest folder projektu
projectno :="O-00001" ;numer projektu (docelowo pochodzący z zewnątrz)
fullfilename = %projectno%.txt ;np. fullfilename :="O-00001.txt" (docelowo będzie tu co innego)
midpath :="-TEST\To_ci_folder\" ; różnica między ścieżką folderu projektu a plikiem TM (docelowo potrzebny regex, bo różne numery dżobów będą stanowiły część nazw folderów)
destpath :=("C:\Users\Właściciel\Documents\AutoHotKey\Do_testowania_skryptów\") ;tu ma trafiać każdy skopiowany plik
fullsourcepath = %sourcepath%%projectno%%midpath% ;pełna ścieżka
;np. fullsourcepath :="C:\Users\Właściciel\Documents\AutoHotKey\Do_testowania_skryptów\CopyFrom\O-00001-TEST\To_ci_folder\"
calasciezka = %fullsourcepath%%fullfilename%
;calasciezka :=("C:\Users\Właściciel\Documents\AutoHotKey\Do_testowania_skryptów\CopyFrom\O-00001-TEST\To_ci_folder\O-00007.txt")

	
;===============definicja funkcji kopiowania ===================
CopyTM(from, into)
{
global sourcepath, projectno, fullfilename, midpath, destpath, fullsourcepath, calasciezka
	;if FileExist "%fullsourcepath%%fullfilename%"
	if FileExist(from)
		{
			MsgBox, , , Znaleziono %from%. Kopiowanie..., 1
			FileCopy %from%, %into%
			if ErrorLevel   ; i.e. it's not blank or zero.
				MsgBox, Nie skopiowano pliku.
			else	
				MsgBox, Skopiowano plik %from%
		}
	else
		MsgBox Nie znaleziono pliku o nazwie %from%
}	
CopyTM(calasciezka, destpath)
return

;=========== poniżej tej linii jest moduł testowy ============
;if FileExist(calasciezka)
;if FileExist "C:\Users\Właściciel\Documents\AutoHotKey\Do_testowania_skryptów\CopyFrom\O-00001-TEST\To_ci_folder\O-00001.txt"
;{
;		MsgBox, , , Znaleziono %calasciezka%. Kopiowanie...,
;	FileCopy, %calasciezka%, %destpath%
;	if ErrorLevel   ; i.e. it's not blank or zero.
;		MsgBox, Nie skopiowano pliku.
;	else	
;		MsgBox, Skopiowano plik %calasciezka%
;}
;else
;	MsgBox Nie znaleziono pliku o nazwie %calasciezka%