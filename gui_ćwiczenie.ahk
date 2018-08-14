#SingleInstance force
#Include C:\Users\REDDO_PW\Documents\AutoHotKey\listafunkcji.pwf


docel := ("C:\Users\REDDO_PW\Documents\AutoHotKey\")
sors := ("C:\Users\REDDO_PW\Documents\AutoHotKey\Do prób\")
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
;	if Csv = 1
;	if Tmx = 1

;!!! od tego miejsca zawodzi raportowanie
		if !(Csv > 0 && Tmx > 0)
			MsgBox,,, % "Znalezionych plików: " dirlist_result.Length() "`n`nRozpoczynam kopiowanie...", 1
		else ;if !((dirlist_result_csv = False) or (dirlist_result_tmx = False))
			MsgBox,,, % "£¹cznie znalezionych plików: " dirlist_result.Length() ", `n(z czego " csv_count " o rozszerzeniu .csv`ni " dirlist_result_tmx.Length() " o rozszerzeniu .xml)`n`nRozpoczynam kopiowanie..."
		
		
	MsgBox Robim dalej (tu pójdzie CopyTM)






;MsgBox % Numeryplu
	}

