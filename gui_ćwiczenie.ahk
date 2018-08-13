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
;sprawdzenie, czy wprowadzono wymagane dane
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
		
else

Numeryplu := Trim(Numeryplu, "`n")
Sort, Numeryplu, UZ
tablicanumerow := StrToArr(Trim(Numeryplu), "`n")

inputlist_result := CheckInputList(tablicanumerow)
if inputlist_result = False
	return
	
else
	if GetDestFolder(Target) = False
		return
	else
		extns := []
		if Csv = 1
			extns.Push("csv")
		if Tmx = 1
			extns.Push("tmx")
		
		
		

		dirlist_result := DajMiDir(Source, inputlist_result, extns)
			if dirlist_result = False
				return
			else
			

			MsgBox Robim dalej
;sprawdza ju¿ prawid³owoœæ mumerówplu; nastêpny krok: szukanie œcie¿ki






;MsgBox % Numeryplu


