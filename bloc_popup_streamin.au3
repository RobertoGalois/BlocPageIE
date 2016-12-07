;========================================================================================================================================================================
; L'enjeu du truc est de trouver un site de streaming où on trouve la vidéo qu'on veut regarder
; puis une fois sur la page, lancer le script (interface graphique avec un bouton marche/arret) pour que dès qu'une nouvelle fenêtre internet s'ouvre, quelle qu'elle soit
; celle-ci soit refermée aussi sec. Quand on veut arrêter cette règle, on clique sur le bouton arrêt du script
;========================================================================================================================================================================

; Infos compilateur
; Integration d'une icone de programme (Super Mario)
#AutoIt3Wrapper_icon=icon2.ico


; Declarer ses variables convenablement
AutoItSetOption("MustDeclareVars", 1)
; Activation du mode evenementiel
Opt("GUIOnEventMode", 1)


; Constantes des GUI
#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#include <IE.au3>

; Déclaration des variables
Dim $ValueInterrupteur = 0; 1 si en marche, 0 si en arrêt
Dim $TitrePage = ""
Dim $Handle = ""
Dim $CompteurPagesFermees = 0

; Code
$TitrePage = InputBox("Titre de la page de départ", "Entrez le titre de la page: ")

; Creation de la fenetre principale
Dim $FenetrePrincipale = GUICreate("Bloquage des popups chiants", 400, 200, 0, 0)
; Fermer le programme en cas de fermeture d'une fenetre.
GUISetOnEvent($GUI_EVENT_CLOSE, "EndProg")

; Creation des elements de la fenetre principale
Dim $FenetrePrincipale_Interrupteur = GUICtrlCreateButton("Marche", CenterCoord(400,200,200,75)[0],CenterCoord(400,200,200,75)[1],200,75, -1, -1)
GUICtrlSetFont($FenetrePrincipale_Interrupteur, 15, 800, 0, "MS SANS SERIF", 4)
; Association du bouton1 a la fonction bouton1
GUICtrlSetOnEvent($FenetrePrincipale_Interrupteur, FenetrePrincipale_Bouton1)
; Label d'affichage du nombre de pages bloquées
Dim $FenetrePrincipale_LabelCompteur = GUICtrlCreateLabel("Nombre de pages bloquées: " & $CompteurPagesFermees, 20, 20, 300)
; Affichage de la fenetre principale
GUISetState(@SW_SHOW, $FenetrePrincipale)
; Donner le focus directement au bouton marche/arret
ControlFocus($FenetrePrincipale, "", $FenetrePrincipale_Interrupteur)


; boucle infinie d'affichage du programme

while 1
	; Economie du CPU
	Sleep(50)

	; Si l'interrupteur est activé
	If($ValueInterrupteur == 1) Then
		VerifOnglets()
	EndIf
WEnd

; Definition des fonctions event

Func EndProg()
	Exit
EndFunc

Func CenterCoord($widthW, $heighW, $widthO, $heighO)
	Local $returnCoordArray[2] = [int((($widthW-$widthO)/2)),int(((($heighW-$heighO)/2)))]
	return $returnCoordArray
EndFunc


Func FenetrePrincipale_Bouton1()
	Switch ($ValueInterrupteur)
		; Si éteint, on l'allume
		Case 0
			GUICtrlSetData($FenetrePrincipale_Interrupteur, "Arrêt")
			$ValueInterrupteur = 1
		; si allumé, on l'eteint
		case 1
			GUICtrlSetData($FenetrePrincipale_Interrupteur, "Marche")
			$ValueInterrupteur = 0
	EndSwitch
EndFunc

Func oIEList()
	Local $count = 0
	Local $ArraySize

	; compter le nombre d'objets présents
	while 1
		Local $oIE
		$count += 1
		$oIE = _IEAttach("", "instance", $count)
		If(_IEPropertyGet($oIE, "locationurl") == 0) Then
			ExitLoop
		EndIf
	WEnd

	; on stocke le nombre d'objets dans la variable
	$ArraySize = $count
	; On réinitialise le compteur
	$count = 0

	; on crée un tableau comme celui de la variable retour de winlist() et on l'initialise
	Local $tabRet[$ArraySize][2]
	$tabRet[0][0] = $ArraySize-1 ; nombre d'objets IE trouvés au total
	$tabRet[0][1] = -1

	; On stocke les données dans cette variable tableau
	while 1
		Local $oIE
		$count += 1
		$oIE = _IEAttach("", "instance", $count)

		If(_IEPropertyGet($oIE, "locationurl") == 0) Then
			ExitLoop
		EndIf

		$tabRet[$count][0] = _IEPropertyGet($oIE, "title")
		$tabRet[$count][1] = $oIE
	WEnd

	Return $tabRet
EndFunc


; fonction qui, dès qu'une nouvelle page s'ouvre, vérifie toutes les pages et si une n'est pas bonne, elles est close
Func VerifPages()
	; On liste toutes les fenetres IE
	Local $liste = winlist("[CLASS:IEFrame]")
	; si le nombre de fenetres IE est strictement superieur a 1 (qui est notre fenetre de départ), alors on lance la verification
	If($liste[0][0] > 1) Then
		; on check chaque fenetre
		For $count = 1 To $liste[0][0] Step 1
			if(StringInStr($liste[$count][0], $TitrePage) == 0) Then
				WinClose($liste[$count][1])
				;$CompteurPagesFermees += 1
				;GUICtrlSetData($FenetrePrincipale_LabelCompteur, "Nombre de pages bloquées: " & $CompteurPagesFermees)
			EndIf
		Next
	EndIf
EndFunc

Func VerifOnglets()
	Local $count = 1
	while 1
		Local $oIE
		$oIE = _IEAttach("", "instance", $count)
		;MsgBox(0, "", _IEPropertyGet($oIE, "title"))

		If(_IEPropertyGet($oIE, "locationurl") == 0) Then
			ExitLoop
		EndIf

		Dim $CompStrings1 = StringInStr(_IEPropertyGet($oIE, "title"), $TitrePage)
		Dim $CompStrings2 = StringInStr(_IEPropertyGet($oIE, "title"), "hotmail, outlook")

		;MsgBox(0, "", "Avant le if=0: " & $CompStrings1)

		If(($CompStrings1 == 0) OR ($CompStrings1 == 0)) Then


			If(NOT ((_IEPropertyGet($oIE, "title")) == "Accéder à Hotmail, Outlook, l'actualité et plus-MSN France")) Then
				;MsgBox(0, "", "Dans le if=0: " & _IEPropertyGet($oIE, "title"))
				If NOT (_IEQuit($oIE)) Then
					MsgBox(0, "", @error)
				EndIf
				;$CompteurPagesFermees += 1
			EndIf
			;GUICtrlSetData($FenetrePrincipale_LabelCompteur, "Nombre de pages bloquées: " & $CompteurPagesFermees)
		EndIf
		$count +=1
	WEnd
EndFunc

Func ShowoIEList($liste)
	Local $texte = "$liste[0][0]: " & $liste[0][0] & @CRLF

	For $count1 = 1 To $liste[0][0] Step 1
		For $count2 = 0 To 1 Step 1
			$texte = $texte & "$liste[" & $count1 & "][" & $count2 & "]: " & $liste[$count1][$count2] & @CRLF
		Next
	Next
	MsgBox(0, "", $texte)
EndFunc