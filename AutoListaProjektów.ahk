#SingleInstance force
;nie działa; jest słownik pamięci, których kluczami są numery, a dalej nie wiadomo
;
;potrzebne tablice o nazwie dotelowych TM-ek każda -- NIE MA
;potrzebna funkcja, która porównuje sprawdza komórkę 22 czy niepusta i porównuje ją z dostępnymi, 
;a następnie przekazuje je do odpowiedniej tablicy

fileinit := ("tex orders.csv")
;fileinit := ("próbne.csv")


Gui, New,, Segregator eksportów
Gui, Add, Text,, Podaj plik źródłowy, z którego mają zostać wczytane dane.`nMożesz też przeciągnąć i upuścić plik .csv na to okno.
Gui, Add, Edit, r1 vFile wp+10, %A_WorkingDir%
Gui, Add, Button, yp-1.5 x+m w100, Wyszukaj...
Gui, Add, Text, xm, Opcjonalnie wklej poniżej listę numerów projektów, np. O-2018-11111.`nUwaga! Wówczas powyższe pole zostanie zignorowane.
Gui, Add, Edit, r10 vNumeryplu w+180 -WantReturn,
Gui, Add, Text, xp+200 yp+20, Wybierz rozszerzenia plików:
if tmxcheck != False
	Gui, Add, Checkbox, vTmx Check Checked, Pamięć projektu (.tmx)
else
	Gui, Add, Checkbox, vTmx Check, Pamięć projektu (.tmx)
if csvcheck != False
	Gui, Add, Checkbox, vCsv Check Checked, Glosariusz projektu (.csv)
else
	Gui, Add, Checkbox, vCsv Check, Glosariusz projektu (.csv)
Gui, Add, Text, xm, Katalog objęty wyszukiwaniem (wraz z podkatalogami):
Gui, Add, Edit, vSource disabled xm w+340 -WantReturn, %sors%
Gui, Add, Button, yp-1.5 x+m w50, Zmień
Gui, Add, Text, xm, Podaj ścieżkę docelową dla kopiowanych pamięci`n(jeśli nie istnieje, program podejmie próbę jej utworzenia):
Gui, Add, Edit, vTarget w+400 -WantReturn, %docel%
Gui, Add, Button, w100 x50 default, OK
Gui, Add, Button, w100 x+130, Anuluj
Gui, Show
return

ButtonWyszukaj...:
Gui +Disabled
FileSelectFile, file,, %A_WorkingDir%, Wybierz plik raportu z numerami do posegsderegowania, (*.csv)
if ErrorLevel
	file = % A_WorkingDir
Gui, MyGui: +Owner
GuiControl,, File, %file%
Gui -Disabled
Gui, Show
return

GuiDropFiles:
file = % A_GuiEvent
GuiControl,, File, %file%
return

ButtonAnuluj:
GuiClose:
GuiEscape:
Gui, Destroy
ExitApp

ButtonOK:
Gui, Submit, NoHide
MsgBox % "&" Numeryplu "&"
if !Numeryplu
	{
	file := fileinit
	MsgBox %file%
	ColNums := GetColumnNums(file) ;tablica dwuelementowa: 1 to nr kolumny orders, 2 to nr kolumny Target TM
	;ArrToStr(ColNums) ;funkcja kontrolna; do usunięcia/debugowania
	TMsbyOrder(ColNums, file)
	}
else
	MsgBox nie wyszło...
	return
return

;==========================================================================
;==========================================================================
;==========================================================================
;=============================== lista płac ===============================
;==========================================================================
;==========================================================================
;==========================================================================


;=== funkcja do rejestrowania pracy aplikacji (log) ===
LogResult(loginput, target)
	{
	FileAppend, %loginput%`n`n, %target%\copylog.pw
		return
	}


;=== funkcja sprawdza ścieżkę docelową i tworzy ją w razie potrzeby ===
GetDestFolder(destination)
{
if !FileExist(destination)
	{
	MsgBox, , , Nie znaleziono folderu %destination%`n`nTworzę folder..., 1
	FileCreateDir %destination%
		if ErrorLevel
			{
			MsgBox !!! Błąd nr %A_LastError% !!!`nNie udało się utworzyć folderu`n`n%destination%`n`nSprawdź poprawność ścieżki lub uprawnienia do utworzenia folderu.
			return False
			}
		else
			MsgBox, , , Utworzono folder %destination%`n`nPrzechodzę dalej..., 1
	}
else
	MsgBox, , , Folder docelowy %destination% jest prawidłowy.`n`nPrzechodzę dalej..., 1
}

;===== funkcja do kopiowania wszystkiego =====
CopyAllTMs(fromarr, into)
{
Global logfilecontent, debug

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
;			MsgBox, , , % "Znaleziono "fromarr[e]". Kopiowanie...", 0.5
			FileCopy %from%, %into%
			if ErrorLevel   ; i.e. it's not blank or zero.
				{
				count_nieudane += 1
				if A_LastError = 80
					error = %A_LastError%: plik docelowy już istnieje
				else if A_LastError = 5
					error = %A_LastError%: brak dostępu
				else
					{
					error = numer %A_LastError%
					if debug != False
						MsgBox, , , % "!!! Błąd " error " !!!`nNie skopiowano pliku "fromarr[e], %debug%
					}
				logoutput = `n%from%`tLipa!`t%error%
				logfilecontent .= logoutput
				}
			else
				{
				count_copied += 1
				if debug != False
					MsgBox, , , % "Skopiowano plik "fromarr[e]"`ndo folderu`n "into, %debug%
				logoutput = `n%from%`tOK
				logfilecontent .= logoutput
				}
		}
	else
		{
		count_nonexisting += 1
		MsgBox, , , Nie znaleziono pliku o nazwie %from%, 0.5
		logoutput = `n%from%`tLipa!`tNie znaleziono pliku
		logfilecontent .= logoutput
		}
	}
	
	failcount := (count_nieudane + count_nonexisting)
	if failcount = 0
		{
		MsgBox, , , Skopiowano wszystkie znalezione pliki (czyli %count_copied%)., 3
		logoutput = `n`tSkopiowano wszystkie znalezione pliki (czyli %count_copied%).
		logfilecontent .= "`n" logoutput
		}
	else
		{
		summary = Skopiowano pliki: (łącznie %count_copied%)
		MsgBox, , , %summary%.`nPełny raport w dostępny w pliku copylog.pw w folderze docelowym., 4
		logoutput = `n`n%summary%
		logfilecontent .= "`n" logoutput
		}
	return
}


;========== funkcja sprawdzająca, czy elementy tablicy spełniają kryteria RegEx ===========
CheckInputList(input)
{
properlist := [] ;tablica elementów zgodnych z definicją, zwracana na koniec
inputcount = 0
	For e in input
		{
	inputcount += 1
	if RegExMatch(input[e], "^(O-20[0-9]{2}-[0-9]{5})$")
		properlist.Push(input[e])
		}
if properlist.Length() = 0
	{
	MsgBox Żaden z podanych numerów nie jest prawidłowy`n(prawidłowy format to: O-2018-11111)
		return False
	}	
else
	{
	l := properlist.Length()
	ml := Mod(l, 10)
	if l = 1
		MsgBox, , , % "Podano " properlist.Length() " formalnie prawidłowy numer projektu.`n`nTrwa wyszukiwanie plików...", 1
	else if (ml = 1 or ml > 4)
		MsgBox, , , % "Podano " properlist.Length() " formalnie prawidłowych numerów projektów.`n`nTrwa wyszukiwanie plików...", 1
	else if ml < 5
		MsgBox, , , % "Podano " properlist.Length() " formalnie prawidłowe numery projektów.`n`nTrwa wyszukiwanie plików...", 1
	return properlist
	}
}

;=========== funkcja do znajdowania plików o konkretnym rozszerzeniu w dół ścieżki, która zwraca listę pełnych ścieżek tych plików ========
DajMiDir(initdir, numeryplu, ext) ;initdir = ścieżka, poniżej której szukamy; ext = rozszerzenie plików
{
global Target, logfilecontent, debug
	unfound :=
	falselist := []
	usedlist := 
	dirlist := [] ;tablica do przechowywania pełnych ścieżek przed zwróceniem ich przez funkcję
		For t in numeryplu
		{
		numer := numeryplu[t]
		numer_plus := "\"numeryplu[t]"."
		fullinitdir = %initdir%\%numer%
		Loop Files, %fullinitdir%\*.%ext%, R  ; Recurse into subfolders.
			{
			filedirname = %A_LoopFileLongPath%
			if (InStr(filedirname, numeryplu[t],,, 2) && InStr(filedirname, numer_plus))
				{
				dirlist.Push(filedirname)
				usedlist .= numer
				}
			else 
				{
				}
			}
		}

For n in numeryplu
	{
	if !InStr(usedlist, numeryplu[n])
				unfound .= "`n" numeryplu[n] "`tLipa!`tNie znaleziono pliku ." ext "`n"
		
	}
Sort, unfound, UZ
logfilecontent .= unfound
	
	dobre := dirlist.Length()
	if dirlist.Length() = 0
		{
		if debug != False
			MsgBox, , , W ścieżce %initdir% nie znaleziono następujących plików z rozszerzeniem .%ext% w folderach o takim samym numerze:`n`n%falselist%, %debug%
		return False
		}
	else
		{
		if debug != False
			MsgBox, , , Liczba plików spełniających kryteria: %dobre%, %debug%
		return dirlist
		}
		
}

;==========
TMsbyOrder(ColNum, sourcefile) ;funkcja, która czyta plik .csv, tworzy parę klucz (nr projektu) -- wartość (docelowa TM) i generuje słownik
{
TargetTM := []
tm_list :=
ColOrd = % ColNum[1]
ColTar = % ColNum[2]
;MsgBox % "ColOrd
MsgBox % "ColOrd: " ColOrd "`nColTar: " ColTar
FileRead, content, %sourcefile%
Loop, parse, content, `n
	{
	if A_Index > 1
		{
		line := StrSplit(A_LoopField, ";")
;		MsgBox %A_LoopField%
		trimmed = % Trim(line[ColTar], "`n`r ")
		if RegExMatch(trimmed, "^\p{Lu}\p{Lu}-\p{Lu}\p{Lu}")
;		if StrLen(trimmed) > 5
			{
;			MsgBox % StrLen(line[ColTar])
;			MsgBox % "nr linii: " A_Index "`nnr linii 22: " trimmed "&"
			tm_list .= trimmed "#`n"
;			MsgBox sss%tm_list%sss
			}	
		}
	}
tm_list = % Trim(tm_list)
Sort, tm_list, UZ
MsgBox pełna lista projektów:`n %tm_list%
		
TM_arr := StrToArr(tm_list)
;MsgBox % "tablica wygląda tak: aaa" ArrToStr(TM_arr) "aaa"
;MsgBox % "TM_arr ma długość " TM_arr.Length() " elementów"
	for n in TM_arr
		{
		MsgBox % "element " n " to >>" TM_arr[n] "<<"
		
		}
	tm_list_length = % TM_arr.Length()
;	MsgBox TM_%tm_list_length%

for n in TM_arr
	{
	Loop, parse, content, `n
		{
		line := StrSplit(A_LoopField, ";")
;		MsgBox %A_LoopField%
		temp := TM_arr[n]
		trimmed = % Trim(line[ColTar], "`n`r ")
		if InStr(temp, trimmed) && StrLen(trimmed) > 5
			{
			MsgBox % "nazwa " trimmed " zawiera sie w " temp ",`nwięc dodaję " line[ColOrd] " do listy."
			TM_arr[n] .= "`n" line[ColOrd]
			}
		}
;	MsgBox % TM_arr[n]
	}
ArrToStr(TM_arr)
return 
}

;	for n in TM_arr
;			{
;			temp := TM_%tm_list_length% 
;			temp .= TM_arr[n] "#`n"
;			if InStr(temp, trimmed)
;				temp .= trimmed "`n"
;			MsgBox %temp%
;			}
		



;funkcja, która czyta nagłówki kolumn i zwraca numery kolumn od zamówień i docelowych termbaz
GetColumnNums(sourcefile)
{
FileReadLine, line_one, %sourcefile%, 1
headings := StrSplit(line_one, ";")
MsgBox %line_one%
ColNums := []
for c in headings
	{
	if InStr(headings[c], "Orders")
		ColNums.Push(c)
	if InStr(headings[c], "Target TM")
		ColNums.Push(c)
	}
return ColNums
}
	
;=== funkcja do przekształcania ciągu tekstowego w tablicę ====
StrToArr(str, delim:="`n")
{
arr := []
Loop, parse, str, %delim%
	{
	line := Trim(A_LoopField, "`n`r`t ")
	if StrLen(line) != 0
		{
;		MsgBox dodano do tablicy wiersz %line%
		arr.Push(line)
		}
	}
return arr
}
	

;=========== funkcja do tworzenia listy z treści tablicy (zwykle do MsgBox i innych form sprawdzenia) ======
ArrToStr(array, delim:="`n")
{
	listarr := ;zmienna tekstowa odpowiadająca treści tablicy w ramach tej funkcji (tylko do wyświetlania w MsgBox)
	For i in array
		listarr .= array[i]delim
	
	if array.Length() = 0
		MsgBox,, ArrToStr, % "Wygląda, że ta tablica jest pusta:("
	else
		MsgBox,, ArrToStr, % "Z zadanej listy pasuje tyle elementów: " array.Length()"`n`nA są to następujące elementy:`n`n"RTrim(listarr, delim)
return RTrim(listarr, delim)
}








