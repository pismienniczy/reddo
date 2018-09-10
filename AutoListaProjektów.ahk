#SingleInstance force

; 0. Instalacja pliku .ini
inicontent := ("###plik konfiguracyjny narzędzia ExportSegregator.exe###`nAutor: Piotr Wielecki`nWersja: wrzesień 2018 r.`nWyłączność użytkowania: REDDO Translations`n`n[Dirs]`ndomyślne ścieżki:`nsors=-->Tu należy wpisać przeszukiwaną ścieżkę<--`ndocel=-->Tu należy podać ścieżkę docelową<--`n`n[CheckBoxes]`nokreśla, czy pola dla tych typów plików mają być domyślnie zaznaczone`n`ntmxcheck=False`ncsvcheck=True`n`n[Odrobaczanie]`nmoże mieć wartość Boole'a albo liczbową; wówczas jest to liczba sekund wyświetlania odrobaczających okien informacyjnych.`n`ndebug=False`n###koniec pliku###")

if !FileExist("ExportSegregator.ini")
	{
	FileAppend, %inicontent%, ExportSegregator.ini
	if ErrorLevel
		MsgBox, 48,, Nie udało się utworzyć pliku konfiguracyjnego.`nSprawdź uprawnienia dostępu i spróbuj ponownie.
	else
		MsgBox, 48,, Przy pierwszym uruchomieniu należy ustawić`nścieżkę źródłową i docelową w pliku ExportSegregator.ini.`nMożna tam też ustawiać inne parametry.`nDobrej zabawy!
	Run "ExportSegregator.ini"
	return
	}

; 0. Odczyt parametrów z pliku .ini (+awaryjne parametry domyślne)
IniRead, sors_var, ExportSegregator.ini, Dirs, sors, --<Tu należy wpisać przeszukiwaną ścieżkę>--
IniRead, docel_var, ExportSegregator.ini, Dirs, docel, --<Tu należy podać ścieżkę docelową>--
IniRead, tmxcheck_var, ExportSegregator.ini, CheckBoxes, tmxcheck, True
IniRead, csvcheck_var, ExportSegregator.ini, CheckBoxes, csvcheck, True
IniRead, debug_var, ExportSegregator.ini, Odrobaczanie, debug, False

sors := sors_var
docel := docel_var
tmxcheck = % tmxcheck_var
csvcheck = % csvcheck_var
debug = % debug_var

;===========
logfilecontent := ;zmienna przechowująca dane logu przed ich ostateczną publikacją
pole := "  `n"

; 1. definicja interfejsu graficznego
Gui, New,, Segregator eksportów
Gui, Add, Text,, Podaj plik źródłowy, z którego mają zostać wczytane dane.`nMożesz też przeciągnąć i upuścić plik .csv na to okno.
Gui, Add, Edit, r1 vFile wp+10, %A_WorkingDir%
Gui, Add, Button, yp-1.5 x+m w100, Wyszukaj...
Gui, Add, Text, xm, Opcjonalnie wklej poniżej listę numerów projektów, np. O-2018-11111.`nUwaga! Jeśli powyżej podano nazwę pliku, wklejona lista zostanie zignorowana.
Gui, Add, Edit, r10 vNumeryplu w+200 -WantReturn,
Gui, Add, Text, xp+220 yp+20, Wybierz rozszerzenia plików:
if tmxcheck != False
	Gui, Add, Checkbox, vTmx Check Checked, Pamięć projektu (.tmx)
else
	Gui, Add, Checkbox, vTmx Check, Pamięć projektu (.tmx)
if csvcheck != False
	Gui, Add, Checkbox, vCsv Check Checked, Glosariusz projektu (.csv)
else
	Gui, Add, Checkbox, vCsv Check, Glosariusz projektu (.csv)
Gui, Add, Text, xm, Katalog objęty wyszukiwaniem (wraz z podkatalogami):
Gui, Add, Edit, r1 vSource disabled xm w+340 -WantReturn, %sors%
Gui, Add, Button, yp-1.5 x+m w50, Zmień
Gui, Add, Text, xm, Podaj ścieżkę docelową dla kopiowanych pamięci`n(jeśli nie istnieje, program podejmie próbę jej utworzenia):
Gui, Add, Edit, r1 vTarget w+400 -WantReturn, %docel%
Gui, Add, Button, w100 x50 default, OK
Gui, Add, Button, w100 x+120, Anuluj
Gui, Show

if debug != False
	{
	SplashTextOn, 140, 19, Eksporter pamięci, [Tryb odrobaczania]
	Sleep 3000
	SplashTextOff
	}
return

ButtonZmień:
GuiControl, enable, %sors%
Gui, Submit, NoHide
return

ButtonWyszukaj...:
;Gui, Submit, NoHide
;GuiControl, disable, %pole%
;Numeryplu := ""
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
Debugger("Ścieżka pliku logu: " Target "\general.log.txt")
FileCreateDir, %Target%

if debug != False
	{
	FileAppend, !!! To jest tryb odrobaczania !!!`n, %Target%\general.log.txt
	logfilecontent .= "!!! To jest tryb odrobaczania !!!`n"
	}

StartTime := A_TickCount
FormatTime, log_time,, dd-MM-yyyy, HH:mm:ss
logdate = %log_time%
logfilecontent .= "`n`t" logdate "`n----------"

if (Source = "")
	{
	MsgBox Ścieżka źródłowa nie może być pusta!`nZbyt krótka ścieżka wydłuży wyszukiwanie w nieskończoność!
		return
	}
if (Tmx = 0) && (Csv = 0)
	{
	MsgBox Zaznacz przynajmniej jeden rodzaj plików!
		return
	}

FileAppend, `t***Początek logu***`n`t%logdate%`n---`n`n, %Target%\general.log.txt

	if !InStr(file, ".") && !Numeryplu
		{
		MsgBox Nie wybrano pliku albo nie podano numeru.`nSpróbuj jeszcze raz.
		return
		}
else if InStr(file, ".")
	{
	MsgBox,,, % "Wczytuję dane z pliku " file "...", 1.2
	ColNums := GetColumnNums(file) ;tablica dwuelementowa: 1 to nr kolumny orders, 2 to nr kolumny Target TM
	if ColNums = 0
		{
		MsgBox Wybrano nieprawidłowy plik`n%sourcefile%.`nSprawdź plik i ponów próbę.
		return
		}
	;ArrToStr(ColNums) ;funkcja kontrolna; do usunięcia/debugowania
	Project_TM_array := TMsbyOrder(ColNums, file)
	Debugger("Przekazana tablica folder#numer`nnumer`nnumer ma długość: " Project_TM_array.Length() " elementów.")
	if Project_TM_array = 0
		{
		MsgBox Wybrano nieprawidłowy plik`n%sourcefile%.`nSprawdź plik i ponów próbę.
		return
		}
	for r in Project_TM_array ;przeszukiwanie tablicy folder#numer`nnumer`nnumer...
		{
		line = % Project_TM_array[r]
	Debugger(Project_TM_array[r])
	FileAppend, Uzyskano przyporządkowanie: %line%`n, %Target%\general.log.txt
		TargetFolderWithNumbers := StrSplit(Project_TM_array[r], "#")
		tablicanumerow := StrToArr(Trim(Project_TM_array[r]), "`n")
		inputlist_result := CheckInputList(tablicanumerow)
		TargetFolderName := TargetFolderWithNumbers[1]
		TargetPath = %Target%\%TargetFolderName%
	Debugger("Tak wygląda ścieżka docelowa: " TargetPath)
		if GetDestFolder(TargetPath) = False
			{
		Debugger("Funkcja GetDestFolder dla ścieżki " TargetPath " zwróciła Fałsz")
		FileAppend, Funkcja GetDestFolder dla ścieżki %TargetPath% zwróciła Fałsz`n, %Target%\general.log.txt
			continue
			}	
SplashTextOn, 240, 50, Trwa kopiowanie`, cierpliwości..., Gdy proces się zakończy, to okno zniknie :)
WinMove, Trwa kopiowanie,, 0,0
	
		if Csv = 1
			dirlist_result_csv := DajMiDir(Source, inputlist_result, "csv")
		if Tmx = 1
			dirlist_result_tmx := DajMiDir(Source, inputlist_result, "tmx")	
		if (dirlist_result_csv = False && dirlist_result_tmx = False)
			{
			Debugger("Nie znaleziono żadnych plików pasujących do pamięci " TargetFolderName)
			FileAppend, Nie znaleziono żadnych plików pasujących do pamięci %TargetFolderName%`n, %Target%\general.log.txt
				continue
			}
		else
			{
;sprawozdanie z tego, co znaleziono
			csv_count = 0
			tmx_count = 0
			dirlist_result := []
			if Csv = 1
				{
				if dirlist_result_csv = False
					{
					Debugger("Nie znaleziono plików z rozszerzeniem .csv dla pamięci " TargetFolderName)
						FileAppend, Nie znaleziono plików z rozszerzeniem .csv dla pamięci %TargetFolderName%`n, %Target%\general.log.txt

					}
				else
					for d in dirlist_result_csv
						{
						dirlist_result.Push(dirlist_result_csv[d])
						csv_count += 1
						}
				}	
			if Tmx = 1
				{
				if dirlist_result_tmx = False
					{
					Debugger("Nie znaleziono plików z rozszerzeniem .tmx dla pamięci " TargetFolderName)
						FileAppend, Nie znaleziono plików z rozszerzeniem .tmx dla pamięci %TargetFolderName%`n, %Target%\general.log.txt
					}
				else
					for d in dirlist_result_tmx
						{
						dirlist_result.Push(dirlist_result_tmx[d])
						tmx_count +=1
						}
				}

		if !(Csv > 0 && Tmx > 0)
			{
		Debugger("Znalezionych plików dla pamięci " TargetFolderName ": " dirlist_result.Length() "`n`nRozpoczynam kopiowanie...")
			FileAppend, Znaleziono pliki dla pamięci %TargetFolderName%`n, %Target%\general.log.txt
			}
		else
			{
			Debugger("Łącznie znalezionych plików dla pamięci " TargetFolderName ": " dirlist_result.Length() ", `n(z czego " csv_count " o rozszerzeniu .csv`ni " dirlist_result_tmx.Length() " o rozszerzeniu .tmx)`n`nRozpoczynam kopiowanie...")
			FileAppend, Znaleziono pliki dla pamięci %TargetFolderName%`n, %Target%\general.log.txt
			}
		}
; sedno sprawy, czyli kopiowanie wszystkiego we właściwe miejsca
logfilecontent .= "`n"

CopyAllTMs(dirlist_result, TargetPath)

ElapsedTime := ((A_TickCount - StartTime)/1000)
logfilecontent .= "`n==========`n"

LogResult(logfilecontent, TargetPath)

FileAppend, `n%TargetFolderName%`t%logfilecontent%`n, %Target%\general.log.txt
		}
SplashTextOff

logfilecontent .= "`n"
ElapsedTime := ((A_TickCount - StartTime)/1000)
FileAppend, `n`tCałkowity czas operacji: %ElapsedTime% s.`n==========`n, %Target%\general.log.txt



	}
else ;poniżej jest człon, który działa na starych zasadach -- pobiera tylko numery projektów, nie tworzy folderów docelowych
	{
	Numeryplu := Trim(Numeryplu, "`n")
Sort, Numeryplu, UZ
tablicanumerow := StrToArr(Trim(Numeryplu), "`n")
;sprawdzenie wprowadzonych danych pod względem formalnym (długość numeru)
inputlist_result := CheckInputList(tablicanumerow)
if !inputlist_result
	{
	MsgBox Żaden z podanych numerów nie jest prawidłowy`n(prawidłowy format to: O-2018-11111).
	return
	}
;sprawdzenie istnienia/utworzenie folderu docelowego	
else if !inputlist_result = False
		{
	if GetDestFolder(Target) = False
		return
		
;ustalenie i uzyskanie pełnych ścieżek konkretnych plików przed ich skopiowaniem		
	
SplashTextOn, 240, 50, Trwa kopiowanie`, cierpliwości..., Gdy proces się zakończy, to okno zniknie :)
WinMove, Trwa kopiowanie,, 0,0
	
		if Csv = 1
			dirlist_result_csv := DajMiDir(Source, inputlist_result, "csv")
		if Tmx = 1
			dirlist_result_tmx := DajMiDir(Source, inputlist_result, "tmx")	
		if (dirlist_result_csv = False && dirlist_result_tmx = False)
			{
				MsgBox Nie znaleziono żadnych plików spełniających kryteria.
				return
			}
		else
;sprawozdanie z tego, co znaleziono
			csv_count = 0
			tmx_count = 0
			dirlist_result := []
			if Csv = 1
				{
				if dirlist_result_csv = False
						Debugger("Nie znaleziono plików z rozszerzeniem .csv")
				else
					for d in dirlist_result_csv
						{
						dirlist_result.Push(dirlist_result_csv[d])
						csv_count += 1
						}
				}	
			if Tmx = 1
				{
				if dirlist_result_tmx = False
						Debugger("Nie znaleziono plików z rozszerzeniem .tmx")
				else
					for d in dirlist_result_tmx
						{
						dirlist_result.Push(dirlist_result_tmx[d])
						tmx_count +=1
						}
				}

		if !(Csv > 0 && Tmx > 0)
			MsgBox, , , % "Znalezionych plików: " dirlist_result.Length() "`n`nRozpoczynam kopiowanie...", 1
		else
			MsgBox, , , % "Łącznie znalezionych plików: " dirlist_result.Length() ", `n(z czego " csv_count " o rozszerzeniu .csv`ni " dirlist_result_tmx.Length() " o rozszerzeniu .xml)`n`nRozpoczynam kopiowanie...", 1

; sedno sprawy, czyli kopiowanie wszystkiego we właściwe miejsca
SplashTextOff


logfilecontent .= "`n"

CopyAllTMs(dirlist_result, Target)

ElapsedTime := ((A_TickCount - StartTime)/1000)
logfilecontent .= "`n`tCałkowity czas operacji: " ElapsedTime " s.`n==========`n"

LogResult(logfilecontent, Target)
		}
	}
MsgBox, 4, Eksporter pamięci, Zakończono kopiowanie.`nCzy chcesz kopiować kolejne pliki?`n`n(kliknięcie „Nie” spowoduje zamknięcie Eksportera)
	IfMsgBox No
		{
		Gui, Destroy
		SplashTextOn, 140, 19, Eksporter pamięci, To paa!
		Sleep 1000
		SplashTextOff
		ExitApp
		}
	else
		logfilecontent :=
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
	FileAppend, %loginput%`n`n, %target%\copylog.pw.txt
		return
	}


;=== funkcja sprawdza ścieżkę docelową i tworzy ją w razie potrzeby ===
GetDestFolder(destination)
{
if !FileExist(destination)
	{
	MsgBox, , , Nie znaleziono folderu %destination%`n`nTworzę folder..., 0.5
	FileCreateDir %destination%
		if ErrorLevel
			{
			MsgBox !!! Błąd nr %A_LastError% !!!`nNie udało się utworzyć folderu`n`n%destination%`n`nSprawdź poprawność ścieżki lub uprawnienia do utworzenia folderu.
			return False
			}
		else
			MsgBox, , , Utworzono folder %destination%`n`nPrzechodzę dalej..., 0.5
	}
else
	MsgBox, , , Folder docelowy %destination% jest prawidłowy.`n`nPrzechodzę dalej..., 0.5
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
				Debugger("!!! Błąd " error " !!!`nNie skopiowano pliku "fromarr[e])
					}
				logoutput = `n%from%`tLipa!`t%error%
				logfilecontent .= logoutput
				}
			else
				{
				count_copied += 1
			Debugger("Skopiowano plik "fromarr[e]"`ndo folderu`n "into)
				logoutput = `n%from%`tOK
				logfilecontent .= logoutput
				}
		}
	else
		{
		count_nonexisting += 1
	Debugger("Nie znaleziono pliku o nazwie " from)
		logoutput = `n%from%`tLipa!`tNie znaleziono pliku
		logfilecontent .= logoutput
		}
	}
	
	failcount := (count_nieudane + count_nonexisting)
	if failcount = 0
		{
		MsgBox, , , Skopiowano wszystkie znalezione pliki (czyli %count_copied%)., 1
		logoutput = `n`tSkopiowano wszystkie znalezione pliki (czyli %count_copied%).
		logfilecontent .= "`n" logoutput
		}
	else
		{
		summary = Skopiowano pliki: (łącznie %count_copied%)
		MsgBox, , , %summary%.`nPełny raport w dostępny w pliku copylog.pw.txt w folderze docelowym., 1
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
	return False
	}	
else
	{
	l := properlist.Length()
	ml := Mod(l, 10)
	if l = 1
		MsgBox, , , % "Podano " properlist.Length() " formalnie prawidłowy numer projektu.`n`nTrwa wyszukiwanie plików...", 0.5
	else if (ml = 1 or ml > 4)
		MsgBox, , , % "Podano " properlist.Length() " formalnie prawidłowych numerów projektów.`n`nTrwa wyszukiwanie plików...", 0.5
	else if ml < 5
		MsgBox, , , % "Podano " properlist.Length() " formalnie prawidłowe numery projektów.`n`nTrwa wyszukiwanie plików...", 0.5
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
	Debugger("plików znaleziono tyle: " dobre)
	if dirlist.Length() = 0
		{
		Debugger("W ścieżce " initdir " nie znaleziono następujących plików z rozszerzeniem ." ext " w folderach o takim samym numerze:`n`n" falselist)
		return False
		}
	else
		{
		Debugger("Liczba plików spełniających kryteria: " dobre)
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
Debugger("ColOrd: " ColOrd "`nColTar: " ColTar)
FileRead, content, %sourcefile%
Loop, parse, content, `n
	{
	if A_Index > 1
		{
		line := StrSplit(A_LoopField, ";")
;		MsgBox %A_LoopField%
		trimmed = % Trim(line[ColTar], "`n`r ")
		if RegExMatch(trimmed, "^\p{Lu}\p{Lu}-\p{Lu}\p{Lu}")
			{
			tm_list .= trimmed "#`n"
			}	
		}
	}
tm_list = % Trim(tm_list)
Sort, tm_list, UZ
Debugger("Pełna lista projektów:`n" tm_list)
		
TM_arr := StrToArr(tm_list)
;MsgBox % "tablica wygląda tak: aaa" ArrToStr(TM_arr) "aaa"
;MsgBox % "TM_arr ma długość " TM_arr.Length() " elementów"
	for n in TM_arr
		{
		Debugger("element " n " to >>" TM_arr[n] "<<")
		
		}
	tm_list_length = % TM_arr.Length()

for n in TM_arr
	{
	Loop, parse, content, `n
		{
		line := StrSplit(A_LoopField, ";")
		Debugger("Oglądam teraz następującą linię ceesfałki:`n" A_LoopField "`npod kątem pamięci o nazwie " TM_arr[n])
		temp := TM_arr[n]
		trimmed = % Trim(line[ColTar], "`n`r ")
		if InStr(temp, trimmed) && StrLen(trimmed) > 5
			{
			Debugger("nazwa " trimmed " zawiera sie w " temp ",`nwięc dodaję " line[ColOrd] " do listy.")
			TM_arr[n] .= "`n" line[ColOrd]
			}
		}
	Debugger("Po dodaniu numerów folderów do nazwy TM-ki jej wiersz nr " n "`nwygląda następująco: " TM_arr[n])
	}
if TM_arr.Length() = 0
	return False
else
	return TM_arr
}

Debugger(message_content, time:="standard")	
{
global debug
if debug != False
	{
	if time = standard
		MsgBox,,, %message_content%, %debug%
	else
		MsgBox,,, %message_content%, %time%
	}
}



;funkcja, która czyta nagłówki kolumn i zwraca numery kolumn od zamówień i docelowych termbaz
GetColumnNums(sourcefile)
{
;global debug
FileReadLine, line_one, %sourcefile%, 1
headings := StrSplit(line_one, ";")
Debugger("Nagłówek: " line_one)
ColNums := []
for c in headings
	{
	if InStr(headings[c], "Orders")
		ColNums.Push(c)
	if InStr(headings[c], "Target TM")
		ColNums.Push(c)
	}
if ColNums.Length() > 0
	return ColNums
else
	{
	Debugger("Wyszło zero elementów, czyli nagłówki się nie zgadzają.")
	return False
	}
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








