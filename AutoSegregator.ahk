#SingleInstance force

; 0. Instalacja pliku .ini
inicontent := ("###plik konfiguracyjny narzêdzia AutoSegregator.exe###`nAutor: Piotr Wielecki`nWersja: paŸdziernik 2018 r.`nWy³¹cznoœæ u¿ytkowania: REDDO Translations`n`n[Dirs]`ndomyœlne œcie¿ki:`nsors=-->Tu nale¿y wpisaæ przeszukiwan¹ œcie¿kê<--`ndocel=-->Tu nale¿y podaæ œcie¿kê docelow¹<--`n`n[CheckBoxes]`nokreœla, czy pola dla tych typów plików maj¹ byæ domyœlnie zaznaczone`n`ntmxcheck=True`ncsvcheck=False`n`n;parametr specjalny -- ignorowanie warunków regex dotycz¹cych umiejscowienia plików wewn¹trz folderu`nignorecheck=False`n`n[Odrobaczanie]`nmo¿e mieæ wartoœæ Boole'a albo liczbow¹; wówczas jest to liczba sekund wyœwietlania odrobaczaj¹cych okien informacyjnych.`n`ndebug=False`n###koniec pliku###")

if !FileExist("AutoSegregator.ini")
	{
	FileAppend, %inicontent%, AutoSegregator.ini
	if ErrorLevel
		MsgBox, 48,, Nie uda³o siê utworzyæ pliku konfiguracyjnego.`nSprawdŸ uprawnienia dostêpu i spróbuj ponownie.
	else
		MsgBox, 48,, Przy pierwszym uruchomieniu nale¿y ustawiæ`nœcie¿kê Ÿród³ow¹ i docelow¹ w pliku AutoSegregator.ini.`nMo¿na tam te¿ ustawiaæ inne parametry.`nDobrej zabawy!
	Run "AutoSegregator.ini"
	return
	}

; 0. Odczyt parametrów z pliku .ini (+awaryjne parametry domyœlne)
IniRead, sors_var, AutoSegregator.ini, Dirs, sors, --<Tu nale¿y wpisaæ przeszukiwan¹ œcie¿kê>--
IniRead, docel_var, AutoSegregator.ini, Dirs, docel, --<Tu nale¿y podaæ œcie¿kê docelow¹>--
IniRead, tmxcheck_var, AutoSegregator.ini, CheckBoxes, tmxcheck, True
IniRead, csvcheck_var, AutoSegregator.ini, CheckBoxes, csvcheck, True
IniRead, ignore_regex_var, AutoSegregator.ini, CheckBoxes, ignorecheck, False
IniRead, debug_var, AutoSegregator.ini, Odrobaczanie, debug, False

sors := sors_var
docel := docel_var
tmxcheck = % tmxcheck_var
csvcheck = % csvcheck_var
debug = % debug_var
ignorecheck = % ignore_regex_var
;===========
logfilecontent := ;zmienna przechowuj¹ca dane logu przed ich ostateczn¹ publikacj¹
pole := "  `n"

; 1. definicja interfejsu graficznego
Gui, New,, Segregator eksportów
Gui, Add, Text,, Podaj plik Ÿród³owy, z którego maj¹ zostaæ wczytane dane.`nMo¿esz te¿ przeci¹gn¹æ i upuœciæ plik .csv na to okno.
Gui, Add, Edit, r1 vFile wp+10, %A_WorkingDir%
Gui, Add, Button, yp-1.5 x+m w100, Wyszukaj...
Gui, Add, Text, xm, Opcjonalnie wklej poni¿ej listê numerów projektów, np. O-2018-11111.`nUwaga! Jeœli powy¿ej podano nazwê pliku, wklejona lista zostanie zignorowana.
Gui, Add, Edit, r10 vNumeryplu w+200 -WantReturn,
Gui, Add, Text, xp+220 yp+20, Wybierz rozszerzenia plików:
if tmxcheck != False
	Gui, Add, Checkbox, vTmx Check Checked, Pamiêæ projektu (.tmx)
else
	Gui, Add, Checkbox, vTmx Check, Pamiêæ projektu (.tmx)
if csvcheck != False
	Gui, Add, Checkbox, vCsv Check Checked, Glosariusz projektu (.csv)
else
	Gui, Add, Checkbox, vCsv Check, Glosariusz projektu (.csv)
if ignorecheck = True
	Gui, Add, Checkbox, yp+50 vIgnore Check Checked, [Szukanie wszêdzie. Nie polecam]
else
	Gui, Add, Checkbox, yp+50 vIgnore Check, [Szukanie wszêdzie. Nie polecam]
Gui, Add, Text, xm, Katalog objêty wyszukiwaniem (wraz z podkatalogami):
Gui, Add, Edit, r1 vSource disabled xm w+340 -WantReturn, %sors%
Gui, Add, Button, yp-1.5 x+m w50, Zmieñ
Gui, Add, Text, xm, Podaj œcie¿kê docelow¹ dla kopiowanych pamiêci`n(jeœli nie istnieje, program podejmie próbê jej utworzenia):
Gui, Add, Edit, r1 vTarget w+400 -WantReturn, %docel%
Gui, Add, Button, w100 x50 default, OK
Gui, Add, Button, w100 x+120, Anuluj
Gui, Show

if debug != False
	{
	SplashTextOn, 140, 19, Eksporter pamiêci, [Tryb odrobaczania]
	Sleep 3000
	SplashTextOff
	}
return

ButtonZmieñ:
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
Debugger("Œcie¿ka pliku logu: " Target "\general.log.txt")
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
	MsgBox Œcie¿ka Ÿród³owa nie mo¿e byæ pusta!`nZbyt krótka œcie¿ka wyd³u¿y wyszukiwanie w nieskoñczonoœæ!
		return
	}
if (Tmx = 0) && (Csv = 0)
	{
	MsgBox Zaznacz przynajmniej jeden rodzaj plików!
		return
	}

FileAppend, `t***Pocz¹tek logu***`n`t%logdate%`n---`n`n, %Target%\general.log.txt

	if !InStr(file, ".") && !Numeryplu
		{
		MsgBox Nie wybrano pliku albo nie podano numeru.`nSpróbuj jeszcze raz.
		return
		}
else if InStr(file, ".")
	{ ;otwarcie ca³ego nowego segmentu ID 1
	MsgBox,,, % "Wczytujê dane z pliku " file "...", 1.2
	ColNums := GetColumnNums(file) ;tablica trzylementowa: 1 to nr kolumny orders, 2 to nr kolumny Target TM, 3 to numer kolumny dla TB
	if ColNums = 0
		{
		MsgBox Wybrano nieprawid³owy plik`n%sourcefile%.`nSprawdŸ plik i ponów próbê.
		return
		}
	if Tmx = 1
		{ ;otwarcie bloku tylko dla TM ID 1.TM
		resource = tmx
		Project_Res_array := ResourcesByOrder(ColNums, file, resource)
		
		Project_Res_array_creator(Project_Res_array, resource)
		} ;zamkniêcie bloku tylko dla TM ID 1.TM

	if Csv = 1
		{ ;otwarcie bloku tylko dla TB ID 1.TB
		resource = csv
		Project_Res_array := ResourcesByOrder(ColNums, file, resource)
		
		Project_Res_array_creator(Project_Res_array, resource)
		} ;zamkniêcie bloku tylko dla TB ID 1.TB	
	
SplashTextOff

logfilecontent .= "`n"
ElapsedTime := ((A_TickCount - StartTime)/1000)
FileAppend, `n`tCa³kowity czas operacji: %ElapsedTime% s.`n==========`n, %Target%\general.log.txt		
	} ;zamkniêcie ca³ego nowego segmentu ID 1
	
else ;poni¿ej jest cz³on, który dzia³a na starych zasadach -- pobiera tylko numery projektów, nie tworzy folderów docelowych
	{
	Numeryplu := Trim(Numeryplu, "`n")
Sort, Numeryplu, UZ
tablicanumerow := StrToArr(Trim(Numeryplu), "`n")
;sprawdzenie wprowadzonych danych pod wzglêdem formalnym (d³ugoœæ numeru)
inputlist_result := CheckInputList(tablicanumerow)
if !inputlist_result
	{
	MsgBox ¯aden z podanych numerów nie jest prawid³owy`n(prawid³owy format to: O-2018-11111).
	return
	}
;sprawdzenie istnienia/utworzenie folderu docelowego	
else if !inputlist_result = False
		{
	if GetDestFolder(Target) = False
		return
		
;ustalenie i uzyskanie pe³nych œcie¿ek konkretnych plików przed ich skopiowaniem		
	
SplashTextOn, 240, 50, Trwa kopiowanie`, cierpliwoœci..., Gdy proces siê zakoñczy, to okno zniknie :)
WinMove, Trwa kopiowanie,, 0,0
	
		if Csv = 1
			dirlist_result_csv := DajMiDir(Source, inputlist_result, "csv")
		if Tmx = 1
			dirlist_result_tmx := DajMiDir(Source, inputlist_result, "tmx")	
		if (dirlist_result_csv = False && dirlist_result_tmx = False)
			{
				MsgBox Nie znaleziono ¿adnych plików spe³niaj¹cych kryteria.
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
			MsgBox, , , % "£¹cznie znalezionych plików: " dirlist_result.Length() ", `n(z czego " csv_count " o rozszerzeniu .csv`ni " dirlist_result_tmx.Length() " o rozszerzeniu .xml)`n`nRozpoczynam kopiowanie...", 1

; sedno sprawy, czyli kopiowanie wszystkiego we w³aœciwe miejsca
SplashTextOff


logfilecontent .= "`n"

CopyAllTMs(dirlist_result, Target)

ElapsedTime := ((A_TickCount - StartTime)/1000)
logfilecontent .= "`n`tCa³kowity czas operacji: " ElapsedTime " s.`n==========`n"

LogResult(logfilecontent, Target)
FileAppend, `nReszta informacji w pliku copylog.pw.txt`n`n`t***Koniec logu***`n, %Target%\general.log.txt
		}
	}
MsgBox, 4, Eksporter pamiêci, Zakoñczono kopiowanie.`nCzy chcesz kopiowaæ kolejne pliki?`n`n(klikniêcie „Nie” spowoduje zamkniêcie Eksportera)
	IfMsgBox No
		{
		Gui, Destroy
		SplashTextOn, 140, 19, Eksporter pamiêci, To paa!
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
;=============================== lista p³ac ===============================
;==========================================================================
;==========================================================================
;==========================================================================

;porz¹dek wywo³ywania (mniej wiêcej)

;funkcja, która czyta nag³ówki kolumn i zwraca numery kolumn od zamówieñ i docelowych folderów TM/TB
GetColumnNums(sourcefile)
{
;global debug
FileReadLine, line_one, %sourcefile%, 1
headings := StrSplit(line_one, ";")
Debugger("Nag³ówek: " line_one)
ColNums := []
for c in headings
	{
	if InStr(headings[c], "Orders")
		ColNums.Push(c)
	if InStr(headings[c], "Target TM")
		ColNums.Push(c)
	if InStr(headings[c], "Domain")
		ColNums.Push(c)
	}
if ColNums.Length() > 0
	{
	Debugger("Tablica z kolumnami ma " ColNums.Length() " elementy d³ugoœci.")
	return ColNums
	}
else
	{
	Debugger("Wysz³o zero elementów, czyli nag³ówki siê nie zgadzaj¹.")
	return False
	}
}
	
ResourcesByOrder(ColNum, sourcefile, tar) ;funkcja, która czyta plik .csv, tworzy trójkê klucz (nr projektu) -- wartoœæ 1 (docelowa TM) -- wartoœæ 2 (docelowa TB) i generuje quasi-s³ownik
{
res_list :=
ColOrd = % ColNum[1]
if tar = tmx
	ColTar = % ColNum[2]
if tar = csv
	ColTar = % ColNum[3]
	
Debugger("ColOrd: " ColOrd "`nColTar: " ColTar)
FileRead, content, %sourcefile%
Loop, parse, content, `n
	{
	if A_Index > 1
		{
		line := StrSplit(A_LoopField, ";")
;		MsgBox %A_LoopField%
		trimmed = % Trim(line[ColTar], "`n`r ")
		if tar = Tmx
			{
			if RegExMatch(trimmed, "^[A-Z]{2}-[A-Z]{2}")
				{
				res_list .= trimmed "#`n"
				}	
			}
		if tar = Csv
			{
			if RegExMatch(trimmed, "^[A-z]{2,}")
				{
				res_list .= trimmed "#`n"
				}	
			}
		}
	}
res_list = % Trim(res_list)
Sort, res_list, UZ
Debugger("Pe³na lista projektów:`n" res_list)
		
Res_arr := StrToArr(res_list)
;MsgBox % "tablica wygl¹da tak: aaa" ArrToStr(Res_arr) "aaa"
;MsgBox % "Res_arr ma d³ugoœæ " Res_arr.Length() " elementów"
	for n in Res_arr
		{
		Debugger("element " n " to >>" Res_arr[n] "<<")
		
		}
	res_list_length = % Res_arr.Length()

for n in Res_arr
	{
	Loop, parse, content, `n
		{
		line := StrSplit(A_LoopField, ";")
		Debugger("Ogl¹dam teraz nastêpuj¹c¹ liniê ceesfa³ki:`n" A_LoopField "`npod k¹tem pamiêci o nazwie " Res_arr[n])
		temp := Res_arr[n]
		trimmed = % Trim(line[ColTar], "`n`r ")
		if InStr(temp, trimmed) && StrLen(trimmed) >= 2 
			{
			Debugger("nazwa " trimmed " zawiera sie w " temp ",`nwiêc dodajê " line[ColOrd] " do listy.")
			Res_arr[n] .= "`n" line[ColOrd]
			}
		}
	Debugger("Po dodaniu numerów folderów do nazwy TM-ki jej wiersz nr " n "`nwygl¹da nastêpuj¹co: " Res_arr[n])
	}
if Res_arr.Length() = 0
	return False
else
	return Res_arr
}

;funkcja do odrobaczania wizualnego
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

;=== funkcja do przekszta³cania ci¹gu tekstowego w tablicê ====
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
	

;=========== funkcja do tworzenia listy z treœci tablicy (zwykle do MsgBox i innych form sprawdzenia) ======
ArrToStr(array, delim:="`n")
{
	listarr := ;zmienna tekstowa odpowiadaj¹ca treœci tablicy w ramach tej funkcji (tylko do wyœwietlania w MsgBox)
	For i in array
		listarr .= array[i]delim
	
	if array.Length() = 0
		MsgBox,, ArrToStr, % "Wygl¹da, ¿e ta tablica jest pusta:("
	else
		MsgBox,, ArrToStr, % "Z zadanej listy pasuje tyle elementów: " array.Length()"`n`nA s¹ to nastêpuj¹ce elementy:`n`n"RTrim(listarr, delim)
return RTrim(listarr, delim)
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
			from := fromarr[e] ; poniewa¿ FileCopy nie obs³uguje elementów tablic
;			MsgBox, , , % "Znaleziono "fromarr[e]". Kopiowanie...", 0.5
			FileCopy %from%, %into%
			if ErrorLevel   ; i.e. it's not blank or zero.
				{
				count_nieudane += 1
				if A_LastError = 80
					error = %A_LastError%: plik docelowy ju¿ istnieje
				else if A_LastError = 5
					error = %A_LastError%: brak dostêpu
				else
					{
					error = numer %A_LastError%
				Debugger("!!! B³¹d " error " !!!`nNie skopiowano pliku "fromarr[e])
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
		summary = Skopiowano pliki: (³¹cznie %count_copied%)
		MsgBox, , , %summary%.`nPe³ny raport w dostêpny w pliku copylog.pw.txt w folderze docelowym., 1
		logoutput = `n`n%summary%
		logfilecontent .= "`n" logoutput
		}
	return
}


;========== funkcja sprawdzaj¹ca, czy elementy tablicy spe³niaj¹ kryteria RegEx ===========
CheckInputList(input)
{
properlist := [] ;tablica elementów zgodnych z definicj¹, zwracana na koniec
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
		MsgBox, , , % "Podano " properlist.Length() " formalnie prawid³owy numer projektu.`n`nTrwa wyszukiwanie plików...", 0.5
	else if (ml = 1 or ml > 4)
		MsgBox, , , % "Podano " properlist.Length() " formalnie prawid³owych numerów projektów.`n`nTrwa wyszukiwanie plików...", 0.5
	else if ml < 5
		MsgBox, , , % "Podano " properlist.Length() " formalnie prawid³owe numery projektów.`n`nTrwa wyszukiwanie plików...", 0.5
	return properlist
	}
}

;=========== funkcja do znajdowania plików o konkretnym rozszerzeniu w dó³ œcie¿ki, która zwraca listê pe³nych œcie¿ek tych plików ========
DajMiDir(initdir, numeryplu, ext) ;initdir = œcie¿ka, poni¿ej której szukamy; ext = rozszerzenie plików
{
global Target, logfilecontent, debug, Ignore
	unfound :=
	falselist := []
	usedlist := 
	dirlist := [] ;tablica do przechowywania pe³nych œcie¿ek przed zwróceniem ich przez funkcjê
		For t in numeryplu
		{
		numer := numeryplu[t]
		numer_plus := "\"numeryplu[t]"."
		
		fullinitdir = %initdir%\%numer%
		
		if Ignore
			{
			Loop Files, %initdir%\%numer%.%ext%
				{
				filedirname = %A_LoopFileLongPath%
			dirlist.Push(filedirname)
			usedlist .= numer
				}
			}
		else
			{
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
		Debugger("W œcie¿ce " initdir " nie znaleziono nastêpuj¹cych plików z rozszerzeniem ." ext " w folderach o takim samym numerze:`n`n" falselist)
		return False
		}
	else
		{
		Debugger("Liczba plików spe³niaj¹cych kryteria: " dobre)
		return dirlist
		}
		
}

; funkcja klej¹ca tablicê z hashykiem dla dowolnego zasobu
Project_Res_array_creator(Project_Res_array, resource)
	{
	global sourcefile, Source, Target
	
	Debugger("Przekazana tablica folder#numer`nnumer`nnumer ma d³ugoœæ: " Project_Res_array.Length() " elementów.")
		if Project_Res_array = 0
			{
			MsgBox Wybrano nieprawid³owy plik`n%sourcefile%.`nSprawdŸ plik i ponów próbê.
			return
			}
		for r in Project_Res_array ;przeszukiwanie tablicy folder#numer`nnumer`nnumer...
			{ ;otwarcie pêtli for ID 1.TM.for
			line = % Project_Res_array[r]
		Debugger(Project_Res_array[r])
		FileAppend, Uzyskano przyporz¹dkowanie: %line%`n, %Target%\general.log.txt
			TargetFolderWithNumbers := StrSplit(Project_Res_array[r], "#")
			tablicanumerow := StrToArr(Trim(Project_Res_array[r]), "`n")
			inputlist_result := CheckInputList(tablicanumerow)
			TargetFolderName := TargetFolderWithNumbers[1]
			TargetPath = %Target%\%TargetFolderName%
		Debugger("Tak wygl¹da œcie¿ka docelowa: " TargetPath)
			if GetDestFolder(TargetPath) = False
				{
			Debugger("Funkcja GetDestFolder dla œcie¿ki " TargetPath " zwróci³a Fa³sz")
			FileAppend, Funkcja GetDestFolder dla œcie¿ki %TargetPath% zwróci³a Fa³sz`n, %Target%\general.log.txt
				continue
				}	
SplashTextOn, 240, 50, Trwa kopiowanie`, cierpliwoœci..., Gdy proces siê zakoñczy, to okno zniknie :)
WinMove, Trwa kopiowanie,, 0,0

		dirlist_result_res := DajMiDir(Source, inputlist_result, resource)
		if (dirlist_result_res = False)
			{
			Debugger("Nie znaleziono ¿adnych plików pasuj¹cych do folderu " TargetFolderName)
			FileAppend, Nie znaleziono ¿adnych plików pasuj¹cych do folderu %TargetFolderName%`n, %Target%\general.log.txt
				continue
			}
		else
			{
			res_count = 0
			dirlist_result := []
			if dirlist_result_res = False
					{
					Debugger("Nie znaleziono plików z rozszerzeniem ." resource " dla folderu " TargetFolderName)
						FileAppend, Nie znaleziono plików z rozszerzeniem .%resource% dla folderu %TargetFolderName%`n, %Target%\general.log.txt
					}
				else
					{
					for d in dirlist_result_res
						{
						dirlist_result.Push(dirlist_result_res[d])
						res_count +=1
						}
				Debugger("Znalezionych plików dla folderu " TargetFolderName ": " dirlist_result.Length() "`n`nRozpoczynam kopiowanie...")
				FileAppend, Znaleziono pliki dla folderu %TargetFolderName%`n, %Target%\general.log.txt
					}
			}
; sedno sprawy, czyli kopiowanie wszystkiego we w³aœciwe miejsca
logfilecontent .= "`n"

CopyAllTMs(dirlist_result, TargetPath)

ElapsedTime := ((A_TickCount - StartTime)/1000)
logfilecontent .= "`n==========`n"

;LogResult(logfilecontent, TargetPath)

FileAppend, `n%TargetFolderName%`t%logfilecontent%`n, %Target%\general.log.txt
			}
	}

;=== funkcja do rejestrowania pracy aplikacji (log) ===
LogResult(loginput, target)
	{
	FileAppend, %loginput%`n`n, %target%\copylog.pw.txt
		return
	}


;=== funkcja sprawdza œcie¿kê docelow¹ i tworzy j¹ w razie potrzeby ===
GetDestFolder(destination)
{
if !FileExist(destination)
	{
	MsgBox, , , Nie znaleziono folderu %destination%`n`nTworzê folder..., 0.5
	FileCreateDir %destination%
		if ErrorLevel
			{
			MsgBox !!! B³¹d nr %A_LastError% !!!`nNie uda³o siê utworzyæ folderu`n`n%destination%`n`nSprawdŸ poprawnoœæ œcie¿ki lub uprawnienia do utworzenia folderu.
			return False
			}
		else
			MsgBox, , , Utworzono folder %destination%`n`nPrzechodzê dalej..., 0.5
	}
else
	MsgBox, , , Folder docelowy %destination% jest prawid³owy.`n`nPrzechodzê dalej..., 0.5
}
