#SingleInstance force
#Include C:\Users\REDDO_PW\Documents\AutoHotKey\listafunkcji.pwf


docel := ("C:\Users\REDDO_PW\Documents\AutoHotKey\")
;MsgBox %projectno%
Gui, New,, Eksporter pamiêci
Gui, Add, Text,, Poni¿ej wklej listê numerów projektów:
Gui, Add, Edit, r10 vNumery w+140 -WantReturn, np. O-2018-11111
Gui, Add, Text, xp+160 y30, Wybierz rozszerzenia plików:
Gui, Add, Checkbox, vTmx Check Checked, .tmx
Gui, Add, Checkbox, vCsv Check Checked, .csv
Gui, Add, Text, xm, Podaj œcie¿kê docelow¹ dla kopiowanych pamiêci:
Gui, Add, Edit, vTarget w+300, %docel%
Gui, Add, Button, w100 x30 Default, OK
Gui, Add, Button, w100 x+60, Anuluj
Gui, Show
return

ButtonAnuluj:
GuiClose:
GuiEscape:
Gui, Destroy
ExitApp

ButtonOK:
Gui, Submit
MsgBox % Numery
;ArrToStr(StrToArr(vNumery))