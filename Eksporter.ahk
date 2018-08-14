#SingleInstance force

StartTime := A_TickCount


docel := ("")
sors := ("D:\Plunet\order\")
;MsgBox %projectno%
Gui, New,, Eksporter pamiêci
Gui, Add, Text,, Poni¿ej wklej listê numerów projektów (np. O-2018-11111),`nktórych pamiêci chcesz skopiowaæ:
Gui, Add, Edit, r10 vNumeryplu w+140 -WantReturn,
Gui, Add, Text, xp+160 y45, Wybierz rozszerzenia plików:
Gui, Add, Checkbox, vTmx Check Checked, .tmx
Gui, Add, Checkbox, vCsv Check Checked, .csv
Gui, Add, Text, xm, Katalog objêty wyszukiwaniem (wraz z podkatalogami):
Gui, Add, Button, yp-5 x+m, Zmieñ
Gui, Add, Edit, vSource disabled xm w+310, %sors%
Gui, Add, Text, xm, Podaj œcie¿kê docelow¹ dla kopiowanych pamiêci`n(jeœli nie istnieje, program podejmie próbê jej utworzenia):
Gui, Add, Edit, vTarget w+310, %docel%
Gui, Add, Button, w100 x30 default, OK
Gui, Add, Button, w100 x+70, Anuluj
Gui, Show
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
						MsgBox,,, Nie znaleziono plików z rozszerzeniem .csv, 1
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
						MsgBox,,, Nie znaleziono plików z rozszerzeniem .tmx, 1
				else
					for d in dirlist_result_tmx
						{
						dirlist_result.Push(dirlist_result_tmx[d])
						tmx_count +=1
						}
				}

		if !(Csv > 0 && Tmx > 0)
			MsgBox,,, % "Znalezionych plików: " dirlist_result.Length() "`n`nRozpoczynam kopiowanie...", 1
		else
			MsgBox,,, % "£¹cznie znalezionych plików: " dirlist_result.Length() ", `n(z czego " csv_count " o rozszerzeniu .csv`ni " dirlist_result_tmx.Length() " o rozszerzeniu .xml)`n`nRozpoczynam kopiowanie...", 1

; sedno sprawy, czyli kopiowanie wszystkiego we w³aœciwe miejsca
CopyAllTMs(dirlist_result, Target)	

		
ElapsedTime := ((A_TickCount - StartTime)/1000)
MsgBox, 4, Eksporter pamiêci, Zakoñczono kopiowanie.`nCa³oœæ trwa³a %ElapsedTime% sekund.`nCzy chcesz kopiowaæ kolejne pliki?`n`n(klikniêcie "Nie" spowoduje zamkniêcie Eksportera)
	IfMsgBox No
		{
		Gui, Destroy
		SplashTextOn, 140, 19, Eksporter pamiêci, To paa!
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
;=============================== lista p³ac ===============================
;==========================================================================
;==========================================================================
;==========================================================================



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
	MsgBox,,, Nie znaleziono folderu %destination%`n`nTworzê folder..., 1
	FileCreateDir %destination%
		if ErrorLevel
			{
			MsgBox !!! B³¹d nr %A_LastError% !!!`nNie uda³o siê utworzyæ folderu`n`n%destination%`n`nSprawdŸ poprawnoœæ œcie¿ki lub uprawnienia do utworzenia folderu.
			return False
			}
		else
	MsgBox,,, Utworzono folder %destination%`n`nPrzechodzê dalej..., 1
	}
else
	MsgBox,,, Folder docelowy %destination% jest prawid³owy.`n`nPrzechodzê dalej..., 1
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
					error = numer %A_LastError%
				MsgBox, , , % "!!! B³¹d " error " !!!`nNie skopiowano pliku "fromarr[e], 0.5
				}
			else
				{
				count_copied += 1
;				MsgBox, , , % "Skopiowano plik "fromarr[e]"`ndo folderu`n "into, 0.5
				}
		}
	else
		{
		count_nonexisting += 1
		MsgBox,,, Nie znaleziono pliku o nazwie %from%, 0.5
		}
	}
	
	failcount := (count_nieudane + count_nonexisting)
	if failcount = 0
		MsgBox Skopiowano wszystkie pliki (czyli %count_copied%).
	else
		MsgBox Sukces : pora¿ka - %count_copied%:%failcount%`n`nSkopiowano nastêpuj¹ce pliki:`n%copied% (³¹cznie %count_copied%)`n`nPlików nieodnalezionych:`n%nonexisting% (³¹cznie %count_nonexisting%)`n`nNie uda³o siê skopiowaæ plików:`n%nieudane% (³¹cznie %count_nieudane%).
}


;========== funkcja sprawdzaj¹ca, czy elementy tablicy spe³niaj¹ kryteria RegEx ===========
CheckInputList(input)
{
properlist := [] ;tablica elementów zgodnych z definicj¹, zwracana na koniec
inputcount = 0
	For e in input
		{
	inputcount += 1
	if RegExMatch(input[e], "(O-20[0-9]{2}-[0-9]{5})")
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
	if l = 1
		MsgBox,,, % "Podano " properlist.Length() " prawid³owy numer projektu.`n`nTrwa wyszukiwanie plików...", 1
	else if l < 5
		MsgBox,,, % "Podano " properlist.Length() " prawid³owe numery projektów.`n`nTrwa wyszukiwanie plików...", 1
	
	else if l > 4
		MsgBox,,, % "Podano " properlist.Length() " prawid³owych numerów projektów.`n`nTrwa wyszukiwanie plików...", 1
	return properlist
	}
}

;=========== funkcja do znajdowania plików o konkretnym rozszerzeniu w dó³ œcie¿ki, która zwraca listê pe³nych œcie¿ek tych plików ========
DajMiDir(initdir, numeryplu, ext) ;initdir = œcie¿ka, poni¿ej której szukamy; ext = rozszerzenie plików
{
	falselist := 
	dirlist := [] ;tablica do przechowywania pe³nych œcie¿ek przed zwróceniem ich przez funkcjê
		For t in numeryplu
		{
		Loop Files, %initdir%\*.%ext%, R  ; Recurse into subfolders.
			{
			filedirname = %A_LoopFileLongPath%
			if InStr(filedirname, numeryplu[t],,, 2)
				dirlist.Push(filedirname)
			else
				falselist .= numeryplu[t]"`n"
			}
		}
	dobre := dirlist.Length()
	if dirlist.Length() = 0
		{
;		MsgBox W œcie¿ce %initdir% nie znaleziono nastêpuj¹cych plików z rozszerzeniem .%ext% w folderach o takim samym numerze:`n`n%falselist%
		return False
		}
	else
		{
;		MsgBox Liczba plików spe³niaj¹cych kryteria: %dobre%
		return dirlist
		}
}
