#SingleInstance force
#Include C:\Users\REDDO_PW\Documents\AutoHotKey\listafunkcji.pwf


docel := ("C:\Users\REDDO_PW\Documents\AutoHotKey\")
sors := ("C:\Users\REDDO_PW\Documents\AutoHotKey\Do pr�b\")
;MsgBox %projectno%
Gui, New,, Eksporter pami�ci
Gui, Add, Text,, Poni�ej wklej list� numer�w projekt�w (np. O-2018-11111),`nkt�rych pami�ci chcesz skopiowa�:
Gui, Add, Edit, r10 vNumeryplu w+140 -WantReturn,
Gui, Add, Text, xp+160 y45, Wybierz rozszerzenia plik�w:
Gui, Add, Checkbox, vTmx Check Checked, .tmx
Gui, Add, Checkbox, vCsv Check Checked, .csv
Gui, Add, Text, xm, Katalog obj�ty wyszukiwaniem (wraz z podkatalogami):
Gui, Add, Button, yp-5 x+m, Zmie�
Gui, Add, Edit, vSource disabled xm w+310, %sors%
Gui, Add, Text, xm, Podaj �cie�k� docelow� dla kopiowanych pami�ci`n(je�li nie istnieje, program podejmie pr�b� jej utworzenia):
Gui, Add, Edit, vTarget w+310, %docel%
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
;sprawdzenie, czy wprowadzono wymagane dane
if (Source = "")
	{
	MsgBox �cie�ka �r�d�owa nie mo�e by� pusta!`nZbyt kr�tka �cie�ka wyd�u�y wyszukiwanie w niesko�czono��!
	return
	}
if (Numeryplu = "") && (Tmx = 0) && (Csv = 0)
	MsgBox Musisz poda� przynajmniej jeden numer projektu`ni zaznaczy� przynajmniej jeden rodzaj plik�w!
else if (Numeryplu = "")
		MsgBox Musisz poda� przynajmniej jeden numer projektu!
else if (Tmx = 0) && (Csv = 0)
		MsgBox Zaznacz przynajmniej jeden rodzaj plik�w!
else

Numeryplu := Trim(Numeryplu, "`n")
Sort, Numeryplu, UZ
tablicanumerow := StrToArr(Trim(Numeryplu), "`n")
if CheckInputList(tablicanumerow) = False
	return
else
	if GetDestFolder(Target) = False
		return
	else
		
		if Csv = 1
			if DajMiDir(Source, tablicanumerow, "csv") = False
				return
			else
				MsgBox Robim dalej
;sprawdza ju� prawid�owo�� mumer�wplu; nast�pny krok: szukanie �cie�ki






;MsgBox % Numeryplu


