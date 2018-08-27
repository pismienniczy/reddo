#SingleInstance force

StartTime := A_TickCount


docel := ("C:\Users\REDDO_PW\Documents\AutoHotKey\Do pr�b\CopyTo")
sors := ("C:\Users\REDDO_PW\Documents\AutoHotKey\Do pr�b\CopyFrom\_oczyszczanie sandbox")
;MsgBox %projectno%
Gui, New,, Eksporter pami�ci
Gui, Add, Text,, Poni�ej wklej list� numer�w projekt�w (np. O-2018-11111),`nkt�rych pami�ci chcesz skopiowa�:
Gui, Add, Edit, r10 vNumeryplu w+140 -WantReturn,
Gui, Add, Text, xp+160 y45, Wybierz rozszerzenia plik�w:
Gui, Add, Checkbox, vTmx Check Checked, .tmx
Gui, Add, Checkbox, vCsv Check Checked, .csv
Gui, Add, Text, xm, Katalog obj�ty wyszukiwaniem (wraz z podkatalogami):
Gui, Add, Button, yp-5 x+m, Zmie�
Gui, Add, Edit, vSource disabled xm w+310 -WantReturn, %sors%
Gui, Add, Text, xm, Podaj �cie�k� docelow� dla kopiowanych pami�ci`n(je�li nie istnieje, program podejmie pr�b� jej utworzenia):
Gui, Add, Edit, vTarget w+310 -WantReturn, %docel%
Gui, Add, Button, w100 x30 default, OK
Gui, Add, Button, w100 x+70, Anuluj
Gui, Show
return

ButtonZmie�:
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

FormatTime, log_time,, dd-MM-yyyy, HH:mm:ss
logdate = %log_time%
FileAppend, `n`t%logdate%`n----------, %target%\copylog.pw
;sprawdzenie, czy wprowadzono wymagane dane (bez wgl�du w ich jako��)

if (Source = "")
	{
	MsgBox �cie�ka �r�d�owa nie mo�e by� pusta!`nZbyt kr�tka �cie�ka wyd�u�y wyszukiwanie w niesko�czono��!
		return
	}
if (Numeryplu = "") && (Tmx = 0) && (Csv = 0)
	{
	MsgBox Musisz poda� przynajmniej jeden numer projektu`ni zaznaczy� przynajmniej jeden rodzaj plik�w!
		return
	}
else if (Numeryplu = "")
	{
	MsgBox Musisz poda� przynajmniej jeden numer projektu!
		return
	}
else if (Tmx = 0) && (Csv = 0)
	{
	MsgBox Zaznacz przynajmniej jeden rodzaj plik�w!
		return
	}
;koniec sprawdzenia wprowadzenia
else
SplashTextOn, 240, 50, Trwa kopiowanie`, cierpliwo�ci..., Gdy proces si� zako�czy, to okno zniknie :)
;WinSet, Transparent, 150, Trwa kopiowanie
WinMove, Trwa kopiowanie,, 0,0

;uzyskanie danych wej�ciowych w formie tablicy 
Numeryplu := Trim(Numeryplu, "`n")
Numeryplu := Trim(Numeryplu, "`n")
Sort, Numeryplu, UZ
tablicanumerow := StrToArr(Trim(Numeryplu), "`n")
;sprawdzenie wprowadzonych danych pod wzgl�dem formalnym (d�ugo�� numeru)
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
;ustalenie i uzyskanie pe�nych �cie�ek konkretnych plik�w przed ich skopiowaniem		
	else
		if Csv = 1
			dirlist_result_csv := DajMiDir(Source, inputlist_result, "csv")
		if Tmx = 1
			dirlist_result_tmx := DajMiDir(Source, inputlist_result, "tmx")	
		if (dirlist_result_csv = False && dirlist_result_tmx = False)
			{
				MsgBox Nie znaleziono �adnych plik�w spe�niaj�cych kryteria.
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
						MsgBox,,, Nie znaleziono plik�w z rozszerzeniem .csv, 1
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
						MsgBox,,, Nie znaleziono plik�w z rozszerzeniem .tmx, 1
				else
					for d in dirlist_result_tmx
						{
						dirlist_result.Push(dirlist_result_tmx[d])
						tmx_count +=1
						}
				}

		if !(Csv > 0 && Tmx > 0)
			MsgBox,,, % "Znalezionych plik�w: " dirlist_result.Length() "`n`nRozpoczynam kopiowanie...", 1
		else
			MsgBox,,, % "��cznie znalezionych plik�w: " dirlist_result.Length() ", `n(z czego " csv_count " o rozszerzeniu .csv`ni " dirlist_result_tmx.Length() " o rozszerzeniu .xml)`n`nRozpoczynam kopiowanie...", 1

; sedno sprawy, czyli kopiowanie wszystkiego we w�a�ciwe miejsca
SplashTextOff

logdetails := CopyAllTMs(dirlist_result, Target)


		
ElapsedTime := ((A_TickCount - StartTime)/1000)
logfilecontent = `n%logdetails% `nCa�kowity czas operacji: %ElapsedTime% s.`n==========`n

LogResult(logfilecontent, Target)

MsgBox, 4, Eksporter pami�ci, Zako�czono kopiowanie.`nCzy chcesz kopiowa� kolejne pliki?`n`n(klikni�cie "Nie" spowoduje zamkni�cie Eksportera)
	IfMsgBox No
		{
		Gui, Destroy
		SplashTextOn, 140, 19, Eksporter pami�ci, To paa!
		Sleep 1000
		SplashTextOff
		ExitApp
		}
	else
		return
	}

;==========================================================================
;==========================================================================
;==========================================================================
;=============================== lista p�ac ===============================
;==========================================================================
;==========================================================================
;==========================================================================


;=== funkcja do rejestrowania pracy aplikacji (log) ===
LogResult(loginput, target)
	{
	FileAppend, %loginput%`n`n, %target%\copylog.pw
		return
	}

;=== funkcja do przekszta�cania ci�gu tekstowego w tablic� ====
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

;=== funkcja sprawdza �cie�k� docelow� i tworzy j� w razie potrzeby ===
GetDestFolder(destination)
{
if !FileExist(destination)
	{
	MsgBox,,, Nie znaleziono folderu %destination%`n`nTworz� folder..., 1
	FileCreateDir %destination%
		if ErrorLevel
			{
			MsgBox !!! B��d nr %A_LastError% !!!`nNie uda�o si� utworzy� folderu`n`n%destination%`n`nSprawd� poprawno�� �cie�ki lub uprawnienia do utworzenia folderu.
			return False
			}
		else
	MsgBox,,, Utworzono folder %destination%`n`nPrzechodz� dalej..., 1
	}
else
	MsgBox,,, Folder docelowy %destination% jest prawid�owy.`n`nPrzechodz� dalej..., 1
}

;===== funkcja do kopiowania wszystkiego =====
CopyAllTMs(fromarr, into)
{

copied :=
count_copied = 0
nieudane := 
count_nieudane = 0
nonexisting :=
count_nonexisting = 0

total_logoutput :=

For e in fromarr
	{

	if FileExist(fromarr[e])
		{
			from := fromarr[e] ; poniewa� FileCopy nie obs�uguje element�w tablic
;			MsgBox, , , % "Znaleziono "fromarr[e]". Kopiowanie...", 0.5
			FileCopy %from%, %into%
			if ErrorLevel   ; i.e. it's not blank or zero.
				{
				count_nieudane += 1
				if A_LastError = 80
					error = %A_LastError%: plik docelowy ju� istnieje
				else if A_LastError = 5
					error = %A_LastError%: brak dost�pu
				else
					error = numer %A_LastError%
;				MsgBox, , , % "!!! B��d " error " !!!`nNie skopiowano pliku "fromarr[e], 0.5
				logoutput = `n%from%`tFail`t%error%
				total_logoutput .= logoutput
				}
			else
				{
				count_copied += 1
;				MsgBox, , , % "Skopiowano plik "fromarr[e]"`ndo folderu`n "into, 0.5
				logoutput = `n%from%`tOK
				total_logoutput .= logoutput
				}
		}
	else
		{
		count_nonexisting += 1
		MsgBox,,, Nie znaleziono pliku o nazwie %from%, 0.5
		logoutput = `n%from%`tFail`tNie znaleziono pliku
		total_logoutput .= logoutput
		}
	}
	
	failcount := (count_nieudane + count_nonexisting)
	if failcount = 0
		{
		MsgBox,,, Skopiowano wszystkie pliki (czyli %count_copied%)., 3
		logoutput = `n`tSkopiowano wszystkie pliki (czyli %count_copied%).
		total_logoutput .= logoutput
		}
	else
		{
		summary = Sukces : pora�ka - %count_copied%:%failcount%`nSkopiowano pliki:`n (��cznie %count_copied%)`nPlik�w nieodnalezionych:`n (��cznie %count_nonexisting%)`nNie uda�o si� skopiowa� plik�w:`n (��cznie %count_nieudane%)
		MsgBox,,, %summary%.`nPe�ny raport w dost�pny w pliku .pw w folderze docelowym., 4
		logoutput = `n`n%summary%
		total_logoutput .= logoutput
		}
	return total_logoutput
}


;========== funkcja sprawdzaj�ca, czy elementy tablicy spe�niaj� kryteria RegEx ===========
CheckInputList(input)
{
properlist := [] ;tablica element�w zgodnych z definicj�, zwracana na koniec
inputcount = 0
	For e in input
		{
	inputcount += 1
	if RegExMatch(input[e], "^(O-20[0-9]{2}-[0-9]{5})$")
		properlist.Push(input[e])
		}
if properlist.Length() = 0
	{
	MsgBox �aden z podanych numer�w nie jest prawid�owy`n(prawid�owy format to: O-2018-11111)
		return False
	}	
else
	{
	l := properlist.Length()
	if l = 1
		MsgBox,,, % "Podano " properlist.Length() " prawid�owy numer projektu.`n`nTrwa wyszukiwanie plik�w...", 1
	else if l < 5
		MsgBox,,, % "Podano " properlist.Length() " prawid�owe numery projekt�w.`n`nTrwa wyszukiwanie plik�w...", 1
	
	else if l > 4
		MsgBox,,, % "Podano " properlist.Length() " prawid�owych numer�w projekt�w.`n`nTrwa wyszukiwanie plik�w...", 1
	return properlist
	}
}

;=========== funkcja do znajdowania plik�w o konkretnym rozszerzeniu w d� �cie�ki, kt�ra zwraca list� pe�nych �cie�ek tych plik�w ========
DajMiDir(initdir, numeryplu, ext) ;initdir = �cie�ka, poni�ej kt�rej szukamy; ext = rozszerzenie plik�w
{
global Target
	falselist := 
	dirlist := [] ;tablica do przechowywania pe�nych �cie�ek przed zwr�ceniem ich przez funkcj�
		For t in numeryplu
		{
		numer := numeryplu[t]
		numer_plus := "\"numeryplu[t]"."
		fullinitdir = %initdir%\%numer%
		Loop Files, %fullinitdir%\*.%ext%, R  ; Recurse into subfolders.
			{
			filedirname = %A_LoopFileLongPath%
			if (InStr(filedirname, numeryplu[t],,, 2) && InStr(filedirname, numer_plus))
				dirlist.Push(filedirname)
			else
;				dirlist.Push(numer)
				falselist .= fullinitdir "`t`t`t`t`t`t`t`t`tFail`tNie znaleziono pliku ." ext "`n"
			}
		}
Sort, falselist, UZ
FileAppend, `n%falselist%, %Target%\copylog.pw
	
	dobre := dirlist.Length()
	if dirlist.Length() = 0
		{
;		MsgBox W �cie�ce %initdir% nie znaleziono nast�puj�cych plik�w z rozszerzeniem .%ext% w folderach o takim samym numerze:`n`n%falselist%
		return False
		}
	else
		{
;		MsgBox Liczba plik�w spe�niaj�cych kryteria: %dobre%
;		dirlist.Push(falselist)
		return dirlist
		}
}
