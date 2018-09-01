#SingleInstance force
debug = False
#Include *i Eksporter.config

logfilecontent :=

if CopyTo != True
	docel := ("--<Tu nale¿y podaæ œcie¿kê docelow¹>--")
if CopyFrom != True
	sors := ("--Tu nale¿y wpisaæ przeszukiwan¹ œcie¿kê--")

;okno interfejsu
Gui, New,, Eksporter pamiêci
Gui, Add, Text,, Poni¿ej wklej listê numerów projektów (np. O-2018-11111),`nktórych pamiêci chcesz skopiowaæ:
Gui, Add, Edit, r10 vNumeryplu w+140 -WantReturn,
Gui, Add, Text, xp+160 y45, Wybierz rozszerzenia plików:
if tmxcheck != False
	Gui, Add, Checkbox, vTmx Check Checked, .tmx
else
	Gui, Add, Checkbox, vTmx Check, .tmx
if csvcheck != False
	Gui, Add, Checkbox, vCsv Check Checked, .csv
else
	Gui, Add, Checkbox, vCsv Check, .csv
Gui, Add, Text, xm, Katalog objêty wyszukiwaniem (wraz z podkatalogami):
Gui, Add, Button, yp-5 x+m, Zmieñ
Gui, Add, Edit, vSource disabled xm w+310 -WantReturn, %sors%
Gui, Add, Text, xm, Podaj œcie¿kê docelow¹ dla kopiowanych pamiêci`n(jeœli nie istnieje, program podejmie próbê jej utworzenia):
Gui, Add, Edit, vTarget w+310 -WantReturn, %docel%
Gui, Add, Button, w100 x30 default, OK
Gui, Add, Button, w100 x+70, Anuluj
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

ButtonAnuluj:
GuiClose:
GuiEscape:
Gui, Destroy
ExitApp

ButtonOK:
Gui, Submit, NoHide

if debug != False
	logfilecontent .= "!!! To jest tryb debugowania !!!`n"

StartTime := A_TickCount
FormatTime, log_time,, dd-MM-yyyy, HH:mm:ss
logdate = %log_time%
logfilecontent .= "`n`t" logdate "`n----------"
;sprawdzenie, czy wprowadzono wymagane dane (bez wgl¹du w ich jakoœæ)

if (Source = "")
	{
	MsgBox Œcie¿ka Ÿród³owa nie mo¿e byæ pusta!`nZbyt krótka œcie¿ka wyd³u¿y wyszukiwanie w nieskoñczonoœæ!
		return
	}
if (Numeryplu = "") && (Tmx = 0) && (Csv = 0)
	{
	MsgBox Musisz podaæ przynajmniej jeden numer projektu`ni zaznaczyæ przynajmniej jeden rodzaj plików!
		return
	}
else if (Numeryplu = "")
	{
	MsgBox Musisz podaæ przynajmniej jeden numer projektu!
		return
	}
else if (Tmx = 0) && (Csv = 0)
	{
	MsgBox Zaznacz przynajmniej jeden rodzaj plików!
		return
	}
;koniec sprawdzenia wprowadzenia
else

;uzyskanie danych wejœciowych w formie tablicy 
Numeryplu := Trim(Numeryplu, "`n")
Numeryplu := Trim(Numeryplu, "`n")
Sort, Numeryplu, UZ
tablicanumerow := StrToArr(Trim(Numeryplu), "`n")
;sprawdzenie wprowadzonych danych pod wzglêdem formalnym (d³ugoœæ numeru)
inputlist_result := CheckInputList(tablicanumerow)
if inputlist_result = False
	{
	MsgBox inputlist_result = %inputlist_result%
	return
	}
;sprawdzenie istnienia/utworzenie folderu docelowego	
else if !inputlist_result = False
	{
	if GetDestFolder(Target) = False
		return
		
;ustalenie i uzyskanie pe³nych œcie¿ek konkretnych plików przed ich skopiowaniem		
	else
	
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
						MsgBox, , , Nie znaleziono plików z rozszerzeniem .csv, 1
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
						MsgBox, , , Nie znaleziono plików z rozszerzeniem .tmx, 1
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

MsgBox, 4, Eksporter pamiêci, Zakoñczono kopiowanie.`nCzy chcesz kopiowaæ kolejne pliki?`n`n(klikniêcie "Nie" spowoduje zamkniêcie Eksportera)
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
	}

;==========================================================================
;==========================================================================
;==========================================================================
;=============================== lista p³ac ===============================
;==========================================================================
;==========================================================================
;==========================================================================


;=== funkcja do rejestrowania pracy aplikacji (log) ===
LogResult(loginput, target)
	{
	FileAppend, %loginput%`n`n, %target%\copylog.pw
		return
	}

;=== funkcja do przekszta³cania ci¹gu tekstowego w tablicê ====
StrToArr(str, delim:="`n")
{
arr := []
Loop, parse, str, %delim%
	{
	line := Trim(A_LoopField, "`n`r`t ")
	arr.Push(line)
	}
return arr
}

;=== funkcja sprawdza œcie¿kê docelow¹ i tworzy j¹ w razie potrzeby ===
GetDestFolder(destination)
{
if !FileExist(destination)
	{
	MsgBox, , , Nie znaleziono folderu %destination%`n`nTworzê folder..., 1
	FileCreateDir %destination%
		if ErrorLevel
			{
			MsgBox !!! B³¹d nr %A_LastError% !!!`nNie uda³o siê utworzyæ folderu`n`n%destination%`n`nSprawdŸ poprawnoœæ œcie¿ki lub uprawnienia do utworzenia folderu.
			return False
			}
		else
			MsgBox, , , Utworzono folder %destination%`n`nPrzechodzê dalej..., 1
	}
else
	MsgBox, , , Folder docelowy %destination% jest prawid³owy.`n`nPrzechodzê dalej..., 1
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
					if debug != False
						MsgBox, , , % "!!! B³¹d " error " !!!`nNie skopiowano pliku "fromarr[e], %debug%
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
		summary = Skopiowano pliki: (³¹cznie %count_copied%)
		MsgBox, , , %summary%.`nPe³ny raport w dostêpny w pliku copylog.pw w folderze docelowym., 4
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
	MsgBox ¯aden z podanych numerów nie jest prawid³owy`n(prawid³owy format to: O-2018-11111)
		return False
	}	
else
	{
	l := properlist.Length()
	ml := Mod(l, 10)
	if l = 1
		MsgBox, , , % "Podano " properlist.Length() " formalnie prawid³owy numer projektu.`n`nTrwa wyszukiwanie plików...", 1
	else if (ml = 1 or ml > 4)
		MsgBox, , , % "Podano " properlist.Length() " formalnie prawid³owych numerów projektów.`n`nTrwa wyszukiwanie plików...", 1
	else if ml < 5
		MsgBox, , , % "Podano " properlist.Length() " formalnie prawid³owe numery projektów.`n`nTrwa wyszukiwanie plików...", 1
	return properlist
	}
}

;=========== funkcja do znajdowania plików o konkretnym rozszerzeniu w dó³ œcie¿ki, która zwraca listê pe³nych œcie¿ek tych plików ========
DajMiDir(initdir, numeryplu, ext) ;initdir = œcie¿ka, poni¿ej której szukamy; ext = rozszerzenie plików
{
global Target, logfilecontent, debug
	unfound :=
	falselist := []
	usedlist := 
	dirlist := [] ;tablica do przechowywania pe³nych œcie¿ek przed zwróceniem ich przez funkcjê
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
			MsgBox, , , W œcie¿ce %initdir% nie znaleziono nastêpuj¹cych plików z rozszerzeniem .%ext% w folderach o takim samym numerze:`n`n%falselist%, %debug%
		return False
		}
	else
		{
		if debug != False
			MsgBox, , , Liczba plików spe³niaj¹cych kryteria: %dobre%, %debug%
		return dirlist
		}
		
}
