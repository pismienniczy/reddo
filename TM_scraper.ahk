;skrypt do hurtowej ekstrakcji TM z folderów plu
/*gotowe funkcje:
-- funkcja CheckInputList(input) - sprawdza tablicę 'input' i zwraca tablicę elementów spełniających kryteria (wbudowane) JAKBY JEST
-- funkcja CopyTM(from, into) kopiująca plik ze ścieżki (zawierającej zmienną) JAKBY JEST
-- funkcja DajMiDir(initdir, ext) zwracająca tablicę ścieżek dla plików z rozszerzeniem 'ext' w głąb śieżki 'initdir' JEST
-- funkcja ArrToStr(funkcja/tablica, delim="`n") do wyświetlania tablic w wygodnej formie tekstowej (domyślny separator `n) JEST
kroki do wykonania:
-- ***pętla na funkcji CopyTM NIEMA***
-- klejenie TM-ek w folderze docelowym NIEMA
-- nakarmienie funkcji danymi (zmiennymi do ścieżki) NIEMA
*/

#SingleInstance force
^\::
;"C:\Users\Właściciel\Documents\AutoHotKey\Do_testowania_skryptów\CopyFrom\O-00001-TEST\To_ci_folder\O-00001.txt"

;lista zmiennych:
sourcepath :=("C:\Users\Właściciel\Documents\AutoHotKey\Do_testowania_skryptów\CopyFrom\") ;tam jest folder projektu
projectno :="O-00001" 							;numer projektu (docelowo pochodzący z zewnątrz)
fullfilename = %projectno%.txt 					;np. fullfilename :="O-00001.txt" (docelowo będzie tu co innego)
midpath :="-TEST\To_ci_folder\" 				;różnica między ścieżką folderu projektu a plikiem TM (docelowo potrzebny regex, bo różne numery dżobów będą stanowiły część nazw folderów)
destpath :=("C:\Users\Właściciel\Documents\AutoHotKey\Do_testowania_skryptów\") ;tu ma trafiać każdy skopiowany plik
fullsourcepath = %sourcepath%%projectno%%midpath% ;pełna ścieżka
;np. fullsourcepath :="C:\Users\Właściciel\Documents\AutoHotKey\Do_testowania_skryptów\CopyFrom\O-00001-TEST\To_ci_folder\"
calasciezka = %fullsourcepath%%fullfilename%
;calasciezka :=("C:\Users\Właściciel\Documents\AutoHotKey\Do_testowania_skryptów\CopyFrom\O-00001-TEST\To_ci_folder\O-00007.txt")

	
;=============== definicja funkcji kopiowania ===================
CopyTM(from, into) ; kiedyś zmienne globalne zostaną włączone do funkcji (gdy znana będzie pełna ścieżka, czy coś tam)
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
;========== definicja szkieletu funkcji, którą można nakarmić TABLICĄ folderów/ścieżek, a ona sprawdzi, co się nada ===========
lista_testowa := ["O-00001", "O-00002", "O-00003", "O-00004", "O-005"]
lista_testowa_pusta := []
;listitem := 

CheckInputList(input) ;funkcja zwraca tablicę elementów zgodnych z definicją
{
properlist := [] ;tablica do przechowywania listy elementów zgodnych z definicją, zwracana na koniec przez tę funkcję

	For e in input
		{
	if RegExMatch(input[e], "O-[0-9]{5,5}")
		properlist.Push(input[e])
		}
	if properlist.Length() = 0
		return properlist
	else
		return properlist
}

;=========== funkcja do znajdowania plików o konkretnym rozszerzeniu w dół ścieżki, która zwraca listę pełnych ścieżek tych plików ========
DajMiDir(initdir, ext) ;initdir = ścieżka, poniżej której szukamy; ext = rozszerzenie pliku
	{
	dirlist := [] ;tablica do przechowywania pełnych ścieżek przed zwróceniem ich przez funkcję
	Loop Files, %initdir%\*.%ext%, R  ; Recurse into subfolders. Tu trzeba dodać rozszerzenie
		{
		filedirname = %A_LoopFileLongPath%
		dirlist.Push(filedirname)
;	    MsgBox, 4, , Filename = %A_LoopFileLongPath%`n`nContinue?
;	    IfMsgBox, No
;	        break
		}
	if dirlist.Length() = 0
		return dirlist
	else
		return dirlist
	}

;=========== definicja funkcji do tworzenia listy z treści tablicy (zwykle do MsgBox i innych form sprawdzenia) ======
ArrToStr(array, delim:="`n")
{
	listarr = ;zmienna tekstowa odpowiadająca treści tablicy w ramach tej funkcji (tylko do wyświetlania w MsgBox)
	For i in array
		listarr .= array[i]delim
	
	if array.Length() = 0
		MsgBox % "Wygląda, że ta tablica jest pusta:("
	else
		MsgBox % "Z zadanej listy pasuje tyle elementów: " array.Length()"`n`nA są to następujące elementy:`n" RTrim(listarr, delim)
	}
listarr :=("C:\Users\Właściciel\Documents\AutoHotKey\Do_testowania_skryptów\CopyFrom")
ext :=("txt")
dirlist := []
;DajMiDir(listarr, ext)
;ArrToStr(CheckInputList(lista_testowa_pusta))
ArrToStr(DajMiDir(listarr, ext))
;przydatna funkcja do pętli na ścieżkach [chwilowo nie działa]
/*
;Msgbox % list_files(A_WinDir)
list_files(Directory)
{
	files =
	Loop, %Directory%\*.*
	{
		files = %files%`n%A_LoopFileName%
	}
	MsgBox % "Takie foldery i pliki się znalazły: " list_files(Directory)
;		return files
}
;MsgBox % "Takie foldery i pliki się znalazły: " list_files(listarr)
list_files(listarr)

return
/* ;to jest wykomentowane ;)
=====================================
clipboard = ; Empty the clipboard.
Msgbox % list_files(WhichFolder)

clipboard = % list_files(WhichFolder)

;list_files(Directory)
;{
; files =
; Loop %Directory%\*.*
; {
; files = %files%`n%A_LoopFileName%
; }
; return files
;}

list_files(Directory)
{
files =
Loop %Directory%\*.*
{
if (files = "")
{
files = %A_LoopFileName%
} else
{
files = %files%; %A_LoopFileName%
}
}
return files
}
return
*/

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