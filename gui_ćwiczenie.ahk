#SingleInstance force
#Include C:\Users\REDDO_PW\Documents\AutoHotKey\listafunkcji.pwf


docel := ("C:\Users\REDDO_PW\Documents\AutoHotKey\")
source := ("C:\Users\REDDO_PW\Documents\AutoHotKey\Do prób\")
;MsgBox %projectno%
Gui, New,, Eksporter pamiêci
Gui, Add, Text,, Poni¿ej wklej listê numerów projektów (np. O-2018-11111),`nktórych pamiêci chcesz skopiowaæ:
Gui, Add, Edit, r10 vNumeryplu w+140 -WantReturn,
Gui, Add, Text, xp+160 y45, Wybierz rozszerzenia plików:
Gui, Add, Checkbox, vTmx Check Checked, .tmx
Gui, Add, Checkbox, vCsv Check Checked, .csv
Gui, Add, Text, xm, Katalog objêty wyszukiwaniem (wraz z podkatalogami):
Gui, Add, Button, yp-5 x+m, Zmieñ
Gui, Add, Edit, vSource disabled xm w+310, %source%
Gui, Add, Text, xm, Podaj œcie¿kê docelow¹ dla kopiowanych pamiêci:
Gui, Add, Edit, vTarget w+310, %docel%
Gui, Add, Button, w100 x30 default, OK
Gui, Add, Button, w100 x+70, Anuluj
Gui, Show
return

ButtonZmieñ:
GuiControl, enable, %source%
return

ButtonAnuluj:
GuiClose:
GuiEscape:
Gui, Destroy
ExitApp

ButtonOK:
Gui, Submit, NoHide
if (Numeryplu = "") && (Tmx = 0) && (Csv = 0)
	MsgBox Musisz podaæ przynajmniej jeden numer projektu`ni zaznaczyæ przynajmniej jeden rodzaj plików!
else if (Numeryplu = "")
		MsgBox Musisz podaæ przynajmniej jeden numer projektu!
else if (Tmx = 0) && (Csv = 0)
		MsgBox Zaznacz przynajmniej jeden rodzaj plików!
else
CheckInputList(StrToArr(Numeryplu))
;sprawdza ju¿ prawid³owoœæ mumerówplu; nastêpny krok: szukanie œcie¿ki






;MsgBox % Numeryplu
