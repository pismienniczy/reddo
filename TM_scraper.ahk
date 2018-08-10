;skrypt do hurtowej ekstrakcji TM z folderów plu
/*gotowe funkcje:
-- funkcja CheckInputList(input) - sprawdza tablicę 'input' i zwraca tablicę elementów spełniających kryteria (wbudowane) JAKBY JEST
-- funkcja CopyAllTMs(fromarr, into) - pętla nakarmiona tablicą ścieżek 'fromarr' sprawdza, czy są prawidłowe i kopiuje każdy z plików
	do folderu wskazanego w zmiennej 'into'
-- funkcja DajMiDir(initdir, ext) zwracająca tablicę ścieżek dla plików z rozszerzeniem 'ext' w głąb śieżki 'initdir' JEST
-- funkcja ArrToStr(funkcja/tablica, delim="`n") do wyświetlania tablic w wygodnej formie tekstowej (domyślny separator `n) JEST
-- funkcja StrToArr(string, delim="`n") do zamiany danych tekstowych na tablice, którymi można nakarmić inne funkcje JEST
-- funkcja GetDestFolder z InputBox do podania folderu docelowego JEST
kroki do wykonania:
-- nakarmienie funkcji danymi plików źródłowych (zmiennymi do ścieżki) BLISKO
-- klejenie TM-ek w folderze docelowym NIEMA

nieużywane:
-- funkcja CopyTM(from, into) kopiująca plik ze ścieżki (zawierającej zmienną) JAKBY JEST

przykładowa ścieżka plunetowa: D:\Plunet\order\O-2018-06355\_TEX
i tam są pliki O-2018-06355.csv i .tmx
(można z niej zrobić parametr domyślny i ew. edytować, podobnie parametrem musi być rozszerzenie (albo lista do zaznaczenia))
[ta kwestia jest do omówienia w ramach specyfikacji]
*/

#SingleInstance force
^\::
;"C:\Users\Właściciel\Documents\AutoHotKey\Do_testowania_skryptów\CopyFrom\O-2018-00001\To_ci_folder\O-00001.txt"

;===lista zmiennych testowych:===
sourcepath :=("C:\Users\Właściciel\Documents\AutoHotKey\Do_testowania_skryptów\CopyFrom\") ;tam jest folder projektu
;sourcepath :=("C:\Users\REDDO_PW\Documents\AutoHotKey\Folder do testowania skryptów")
projectno :="O-2018-00001" 							;numer projektu (docelowo pochodzący z zewnątrz)
fullfilename = %projectno%.txt 					;np. fullfilename :="O-00001.txt" (docelowo będzie tu co innego)
midpath :="\To_ci_folder\" 				;różnica między ścieżką folderu projektu a plikiem TM (docelowo potrzebny regex, bo różne numery dżobów będą stanowiły część nazw folderów)
;destpath :=("C:\Users\Właściciel\Documents\AutoHotKey\Do_testowania_skryptów\") ;tu ma trafiać każdy skopiowany plik
destpath :=("C:\Users\REDDO_PW\Documents\AutoHotKey\Folder do testowania skryptów\CopyTo") ;brak uprawnień administratora do folderu Właściciel
fullsourcepath = %sourcepath%%projectno%%midpath% ;pełna ścieżka
;np. fullsourcepath :="C:\Users\Właściciel\Documents\AutoHotKey\Do_testowania_skryptów\CopyFrom\O-2018-00001\To_ci_folder\"
calasciezka = %fullsourcepath%%fullfilename%
;calasciezka :=("C:\Users\Właściciel\Documents\AutoHotKey\Do_testowania_skryptów\CopyFrom\O-2018-00001\To_ci_folder\O-00007.txt")

;===lista zmiennych docelowych===

ArrToStr(DajMiDir(sourcepath, "txt"))


;=== funkcja generująca listę ścieżek ===
;- lista numerów projektów: sparsować (jak przy koszałku), sprawdzić regexem, przekazać do tablicy
lastclip := Clipboard
Clipboard :=
Sleep 100
Send ^c
Sleep 100

;ArrToStr(StrToArr(Clipboard))

; === funkcja zamieniająca zmienną tekstową w tablicę
StrToArr(str, delim:="`n")
	{
	arr := []
	Loop, parse, str, %delim%
		{
		line := Trim(A_LoopField, "`n`r`t ")
;			{
;		MsgBox #%line%#
		arr.Push(line)
;		MsgBox % arr[1]
;			}
		}
	return arr
	}

defaultdest :=("C:\Users\REDDO_PW\Documents\AutoHotKey\Folder do testowania skryptów\")
;y = defaultdest.Length()
GetDestFolder(defaultdest="C:\Users\REDDO_PW\Documents\AutoHotKey\Folder do testowania skryptów\")
{
InputBox, destination, Podaj folder docelowy, Jeżeli podany folder nie istnieje`, zostanie utworzony`n(o ile to możliwe),, (StrLen(defaultdest) * 8),,,,,, %defaultdest%
if ErrorLevel
	exit
;	MsgBox Nie podano nazwy folderu.
else
	if !FileExist(destination)
		FileCreateDir %destination%
			if ErrorLevel
				{
				MsgBox !!! Błąd nr %A_LastError% !!!`nNie udało się utworzyć folderu`n`n%destination%`n`nSprawdź poprawność ścieżki lub uprawnienia do utworzenia folderu.
				exit
				}
	else
return destination
}

CopyAllTMs(DajMiDir(sourcepath, "txt"), GetDestFolder())

; === lista funkcji ===
CopyAllTMs(fromarr, into)
{
copied :=
count_copied = 0
nieudane := 
count_nieudane = 0
nonexisting :=
count_nonexisting = 0

For e in fromarr
	{

	if FileExist(fromarr[e])
		{
			from := fromarr[e] ; ponieważ FileCopy nie obsługuje elementów tablic
			MsgBox, , , % "Znaleziono "fromarr[e]". Kopiowanie...", 0.5
			FileCopy %from%, %into%
			if ErrorLevel   ; i.e. it's not blank or zero.
				{
				count_nieudane += 1
				if A_LastError = 80
					error = %A_LastError%: plik docelowy już istnieje
				else if A_LastError = 5
					error = %A_LastError%: brak dostępu
				else
					error = numer %A_LastError%
				MsgBox, , , % "!!! Błąd " error " !!!`nNie skopiowano pliku "fromarr[e], 0.5
				}
			else
				{
				count_copied += 1
				MsgBox, , , % "Skopiowano plik "fromarr[e]"`ndo folderu`n "into, 0.5
				}
		}
	else
		{
		count_nonexisting += 1
		MsgBox Nie znaleziono pliku o nazwie %from%
		}
	}
	
	failcount := (count_nieudane + count_nonexisting)
	if failcount = 0
		MsgBox Skopiowano wszystkie pliki (czyli %count_copied%).
	else
		MsgBox Sukces : porażka - %count_copied%:%failcount%`n`nSkopiowano następujące pliki:`n%copied% (łącznie %count_copied%)`n`nPlików nieodnalezionych:`n%nonexisting% (łącznie %count_nonexisting%)`n`nNie udało się skopiować plików:`n%nieudane% (łącznie %count_nieudane%).
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
	if RegExMatch(input[e], "O-20[0-9]{2,2}-[0-9]{5,5}")
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
	listarr := ;zmienna tekstowa odpowiadająca treści tablicy w ramach tej funkcji (tylko do wyświetlania w MsgBox)
	For i in array
		listarr .= array[i]delim
	
	if array.Length() = 0
		MsgBox % "Wygląda, że ta tablica jest pusta:("
	else
		MsgBox % "Z zadanej listy pasuje tyle elementów: " array.Length()"`n`nA są to następujące elementy:`n`n"RTrim(listarr, delim)
}

;DajMiDir(listarr, ext)
;ArrToStr(CheckInputList(lista_testowa_pusta))
;ArrToStr(DajMiDir(listarr, ext))
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
;=============== definicja funkcji kopiowania ***obecnie nieużywana*** ===================
CopyTM(from, into) ; kiedyś zmienne globalne zostaną włączone do funkcji (gdy znana będzie pełna ścieżka, czy coś tam)
{
;global sourcepath, projectno, fullfilename, midpath, destpath, fullsourcepath, calasciezka
	;if FileExist "%fullsourcepath%%fullfilename%"
	if FileExist(from)
		{
			MsgBox, , , Znaleziono %from%. Kopiowanie..., 1
			FileCopy %from%, %into%
			if ErrorLevel   ; i.e. it's not blank or zero.
				{
				count_nieudane += 1
				MsgBox, , , !!!Błąd!!! Nie skopiowano pliku %from%, 1
				}
			else
				{
				count_copied += 1
				MsgBox, , , Skopiowano plik %from%, 1
				}
		}
	else
		{
		count_nonexisting += 1
		MsgBox Nie znaleziono pliku o nazwie %from%
		}
}


;=========== poniżej tej linii jest moduł testowy ============
;if FileExist(calasciezka)
;if FileExist "C:\Users\Właściciel\Documents\AutoHotKey\Do_testowania_skryptów\CopyFrom\O-2018-00001\To_ci_folder\O-00001.txt"
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