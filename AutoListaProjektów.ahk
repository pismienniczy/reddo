#SingleInstance force
;nie działa; jest słownik pamięci, których kluczami są numery, a dalej nie wiadomo
;
;potrzebne tablice o nazwie dotelowych TM-ek każda -- NIE MA
;potrzebna funkcja, która porównuje sprawdza komórkę 22 czy niepusta i porównuje ją z dostępnymi, 
;a następnie przekazuje je do odpowiedniej tablicy

;file := ("tex orders.csv")
file := ("próbne.csv")


ColNums := GetColumnNums(file) ;tablica dwuelementowa: 1 to nr kolumny orders, 2 to nr kolumny Target TM
ArrToStr(ColNums)
	
TMsbyOrder(ColNums, file)



;==========
TMsbyOrder(ColNum, sourcefile) ;funkcja, która czyta plik .csv, tworzy parę klucz (nr projektu) -- wartość (docelowa TM) i generuje słownik
{
TargetTM := []
tm_list :=
ColOrd = % ColNum[1]
ColTar = % ColNum[2]
;MsgBox % "ColOrd
MsgBox % "ColOrd: " ColOrd "`nColTar: " ColTar
FileRead, content, %sourcefile%
Loop, parse, content, `n
	{
	if A_Index > 1
		{
		line := StrSplit(A_LoopField, ";")
;		MsgBox %A_LoopField%
		trimmed = % Trim(line[ColTar], "`n`r ")
		if StrLen(trimmed) > 5
			{
;			MsgBox % StrLen(line[ColTar])
;			MsgBox % "nr linii: " A_Index "`nnr linii 22: " trimmed "&"
			tm_list .= trimmed "#`n"
;			MsgBox sss%tm_list%sss
			}	
		}
	}
tm_list = % Trim(tm_list)
Sort, tm_list, UZ
MsgBox pełna lista projektów:`n %tm_list%
		
TM_arr := StrToArr(tm_list)
;MsgBox % "tablica wygląda tak: aaa" ArrToStr(TM_arr) "aaa"
;MsgBox % "TM_arr ma długość " TM_arr.Length() " elementów"
	for n in TM_arr
		{
		MsgBox % "element " n "to >>" TM_arr[n] "<<"
		
		}
	tm_list_length = % TM_arr.Length()
;	MsgBox TM_%tm_list_length%

for n in TM_arr
	{
	Loop, parse, content, `n
		{
		line := StrSplit(A_LoopField, ";")
;		MsgBox %A_LoopField%
		temp := TM_arr[n]
		trimmed = % Trim(line[ColTar], "`n`r ")
		if InStr(temp, trimmed) && StrLen(trimmed) > 5
			{
			MsgBox % "nazwa " trimmed " zawiera sie w " temp ", więc dodaję " line[ColOrd] " do listy."
			TM_arr[n] .= "`n" line[ColOrd]
			}
		}
;	MsgBox % TM_arr[n]
	}
ArrToStr(TM_arr)
return 
}

;	for n in TM_arr
;			{
;			temp := TM_%tm_list_length% 
;			temp .= TM_arr[n] "#`n"
;			if InStr(temp, trimmed)
;				temp .= trimmed "`n"
;			MsgBox %temp%
;			}
		



;funkcja, która czyta nagłówki kolumn i zwraca numery kolumn od zamówień i docelowych termbaz
GetColumnNums(sourcefile)
{
FileReadLine, line_one, %sourcefile%, 1
headings := StrSplit(line_one, ";")
MsgBox %line_one%
ColNums := []
for c in headings
	{
	if InStr(headings[c], "Orders")
		ColNums.Push(c)
	if InStr(headings[c], "Target TM")
		ColNums.Push(c)
	}
return ColNums
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








