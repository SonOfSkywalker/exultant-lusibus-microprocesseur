; Projet Exultant Lusibus Robot 2 by Raphael CANIN et Yann SOBGUI

		AREA    |.text|, CODE, READONLY
 
; This register controls the clock gating logic in normal Run mode
SYSCTL_PERIPH_GPIO EQU		0x400FE108	; SYSCTL_RCGC2_R (p291 datasheet de lm3s9b92.pdf)

; The GPIODATA register is the data register
GPIO_PORTD_BASE		EQU		0x40007000		; GPIO Port D  <-- Pour les boutons poussoirs

GPIO_PORTE_BASE 	EQU 0x40024000			;GPIO Port E  <-- Pour les Bumpers
	
GPIO_PORTF_BASE		EQU		0x40025000	; GPIO Port F  <-- Pour les LED


; configure the corresponding pin to be an output
; all GPIO pins are inputs by default
GPIO_O_DIR   		EQU 	0x00000400  ; GPIO Direction (p417 datasheet de lm3s9B92.pdf)

; The GPIODR2R register is the 2-mA drive control register
; By default, all GPIO pins have 2-mA drive.
GPIO_O_DR2R   		EQU 	0x00000500  ; GPIO 2-mA Drive Select (p428 datasheet de lm3s9B92.pdf)


; Digital enable register
; To use the pin as a digital input or output, the corresponding GPIODEN bit must be set.
GPIO_O_DEN  		EQU 	0x0000051C  ; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)

; Pul_up
GPIO_I_PUR   		EQU 	0x00000510  ; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)

BROCHE6				EQU 	0x40		; bouton poussoir 1
	
BROCHE7				EQU		0x80		; bouton poussoir 2

BROCHE6_7			EQU		0xC0		; both buttons

BROCHE0 			EQU 	0x01		; right bumper
	
BROCHE1 			EQU		0x02		; left bumper
	
BROCHE0_1			EQU		0x03		; both bumpers
	
BROCHE4				EQU		0x10		; led 1
	
BROCHE5				EQU		0x20		; led 2

BROCHE4_5			EQU		0x30		; both led
	
	
	  	ENTRY
		EXPORT	__main
		
		IMPORT	MOTEUR_DROIT_ON
		IMPORT  MOTEUR_DROIT_OFF
		IMPORT  MOTEUR_DROIT_AVANT
		IMPORT  MOTEUR_DROIT_ARRIERE
		IMPORT  MOTEUR_DROIT_INVERSE
		IMPORT	MOTEUR_GAUCHE_ON
		IMPORT  MOTEUR_GAUCHE_OFF
		IMPORT  MOTEUR_GAUCHE_AVANT
		IMPORT  MOTEUR_GAUCHE_ARRIERE
		IMPORT  MOTEUR_GAUCHE_INVERSE
			
		IMPORT	MOTEUR_INIT_RAPIDE ; Vitesse des deux roues : rapide
		IMPORT	MOTEUR_INIT_DROITE ; Vitesse de la roue droite supérieure à la roue gauche
		IMPORT  MOTEUR_INIT_GAUCHE ; Vitesse de la roue droite supérieure à la roue gauche

		IMPORT PARTIE2 ; La seconde partie de la danse se trouve sur un fichier .s connexe

		EXPORT FIN
		EXPORT WAIT_MESURE
		EXPORT WAIT_BLANCHE
		EXPORT WAIT_NOIRE
		EXPORT WAIT_CROCHE
		EXPORT WAIT_TRIOLET
		EXPORT WAIT_DCROCHE
		EXPORT WAIT_TCROCHE
	
__main	


		;Enable the Port F & D & E peripheral clock
		ldr r6, = SYSCTL_PERIPH_GPIO  			;; RCGC2
        mov r0, #0x00000038  					;; Enable clock sur GPIO D et F et E

        str r0, [r6]
		
		;3 clocks delay
		nop	   									
		nop	   
		nop
		
		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^CONFIGURATION LED

        ldr r7, = GPIO_PORTF_BASE+GPIO_O_DIR    ;; 1 Pin du portF en sortie (broche 4 : 00010000)
        ldr r0, = BROCHE4_5 	
        str r0, [r7]
		
		ldr r7, = GPIO_PORTF_BASE+GPIO_O_DEN	;; Enable Digital Function 
        ldr r0, = BROCHE4_5		
        str r0, [r7]
		
		ldr r7, = GPIO_PORTF_BASE+GPIO_O_DR2R	;; Choix de l'intensité de sortie (2mA)
        ldr r0, = BROCHE4_5			
        str r0, [r7]
		
		
		ldr r4, = GPIO_PORTF_BASE + (BROCHE4<<2)  		; led 1
		ldr r5, = GPIO_PORTF_BASE + (BROCHE5<<2)		; led 2
		
		;vvvvvvvvvvvvvvvvvvvvvvvFin configuration LED 
		
		
		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^CONFIGURATION Switcher 1

		ldr r7, = GPIO_PORTD_BASE+GPIO_I_PUR	;; Pul_up 
        ldr r0, = BROCHE6_7		
        str r0, [r7]
		
		ldr r7, = GPIO_PORTD_BASE+GPIO_O_DEN	;; Enable Digital Function 
        ldr r0, = BROCHE6_7	
        str r0, [r7]     
		
		ldr r7, = GPIO_PORTD_BASE + (BROCHE6_7<<2)		; both buttons
		ldr r8, = GPIO_PORTD_BASE + (BROCHE6<<2)		; bouton poussoir 1
		ldr r9, = GPIO_PORTD_BASE + (BROCHE7<<2)		; bouton poussoir 2
		
		;vvvvvvvvvvvvvvvvvvvvvvvFin configuration Switcher 


		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^CONFIGURATION Bumpers
		
		ldr r7, = GPIO_PORTE_BASE+GPIO_I_PUR	;; Pul_up 
        ldr r0, = BROCHE0_1		
        str r0, [r7]
		
		ldr r7, = GPIO_PORTE_BASE+GPIO_O_DEN	;; Enable Digital Function 
        ldr r0, = BROCHE0_1	
        str r0, [r7] 
		
		ldr r11, = GPIO_PORTE_BASE + (BROCHE0_1<<2)		; both bumpers
		ldr r12, = GPIO_PORTE_BASE + (BROCHE0<<2)		; right bumper --> On ne va pas l'utiliser ici
		ldr r13, = GPIO_PORTE_BASE + (BROCHE1<<2)		; left bumper  --> Idem
		
		;vvvvvvvvvvvvvvvvvvvvvvvFin configuration Bumpers
				
		mov r3, #0x00				;Initialisation de la led 1 éteinte
		str r3, [r4]				;On éteint la led
		mov r3, #BROCHE4			;On place dans le registre r1 la valeur pour allumer la led
		
		mov r2, #0x00				;Initialisation de la led 2 éteinte
		str r2, [r5]				;On éteint la led
		mov r2, #BROCHE5			;On place dans le registre r2 la valeur pour allumer la led


		BL	MOTEUR_INIT_RAPIDE

		str r3,[r4] ; Allume la led droite
		
Switch_attente ; On attend l'appui sur SW1 pour lancer le début de la synchronisation de la séquence de danse
		
		ldr r10,[r8]
		CMP r10,#0x00
		BNE Switch_attente

		
		BL	MOTEUR_DROIT_AVANT	
		BL  MOTEUR_GAUCHE_AVANT
		BL  MOTEUR_DROIT_ON
		BL  MOTEUR_GAUCHE_ON


Bumpers_attente; Si l'un des bumpers sont activés, on lance la danse maintenant synchronisée
		
		ldr r10,[r11]
		CMP r10,#0x03
		BNE Danse
		
		b  Bumpers_attente
		
		str r0,[r4] ; on eteint la led de droite
		
Danse ; Debut de la danse

		BL MOTEUR_INIT_RAPIDE
		BL MOTEUR_GAUCHE_ARRIERE
		BL MOTEUR_DROIT_ARRIERE
		BL WAIT_BLANCHE
		
		BL MOTEUR_GAUCHE_OFF
		BL MOTEUR_DROIT_OFF


		BL WAIT_BLANCHE
		BL WAIT_MESURE
		
		BL WAIT_NOIRE ; permet d'appuyer sur le bumper un temps avant le debut de la musique
		
		BL WAIT_MESURE
		BL WAIT_MESURE
		
		; MESURE 7
		
		BL MOTEUR_GAUCHE_ON
		BL MOTEUR_DROIT_ON
		
		ldr r12,=0x03 ; Boucle FOR évitant la duplication de code
move1
		BL MOTEUR_GAUCHE_AVANT
		BL MOTEUR_DROIT_AVANT
		BL WAIT_NOIRE

		BL MOTEUR_GAUCHE_ARRIERE
		BL MOTEUR_DROIT_ARRIERE
		BL WAIT_NOIRE
		
		subs r12,#1
		bne move1
		
		BL MOTEUR_GAUCHE_AVANT
		BL MOTEUR_DROIT_AVANT
		BL WAIT_NOIRE

		BL MOTEUR_GAUCHE_OFF
		BL MOTEUR_DROIT_OFF
		BL WAIT_NOIRE
		
		
		
		BL WAIT_MESURE
		
		
		BL MOTEUR_GAUCHE_ON
		BL MOTEUR_DROIT_ON
		
		BL MOTEUR_GAUCHE_ARRIERE
		BL MOTEUR_DROIT_ARRIERE
		BL WAIT_NOIRE
		
		BL MOTEUR_GAUCHE_AVANT
		BL MOTEUR_DROIT_AVANT
		BL WAIT_NOIRE
		
		BL MOTEUR_GAUCHE_ARRIERE
		BL MOTEUR_DROIT_ARRIERE
		BL WAIT_NOIRE

		
		BL MOTEUR_GAUCHE_OFF
		BL MOTEUR_DROIT_OFF
		BL WAIT_NOIRE
		
		


	
		BL MOTEUR_GAUCHE_ARRIERE
		BL MOTEUR_DROIT_ARRIERE
		
		
		ldr r12,=0x06
move2
		BL MOTEUR_GAUCHE_ON
		BL MOTEUR_DROIT_OFF
		BL WAIT_TRIOLET
		
		BL MOTEUR_GAUCHE_OFF
		BL MOTEUR_DROIT_ON
		BL WAIT_TRIOLET
		
		subs r12,#1
		bne move2
		
		BL MOTEUR_GAUCHE_ON
		BL MOTEUR_DROIT_ON

		BL MOTEUR_DROIT_AVANT
		BL MOTEUR_GAUCHE_AVANT
		BL WAIT_BLANCHE

		BL MOTEUR_GAUCHE_OFF
		BL MOTEUR_DROIT_OFF
		BL WAIT_BLANCHE
		
	
	; Mesure 11
		BL WAIT_MESURE
		BL WAIT_MESURE
	; Mesure 13
		
		

		BL MOTEUR_GAUCHE_ON
		BL MOTEUR_DROIT_ON
		
		ldr r12,=0x03
move3
		BL MOTEUR_GAUCHE_AVANT
		BL MOTEUR_DROIT_ARRIERE
		BL WAIT_NOIRE
		
		BL MOTEUR_GAUCHE_ARRIERE
		BL MOTEUR_DROIT_AVANT
		BL WAIT_NOIRE
		
		subs r12,#1
		bne move3
		
	
		
		BL MOTEUR_GAUCHE_OFF
		BL MOTEUR_DROIT_OFF
		
		BL WAIT_BLANCHE
		
		

		; Mesure 15
		
		BL MOTEUR_GAUCHE_ON
		BL MOTEUR_DROIT_ON
		
		BL MOTEUR_DROIT_ARRIERE
		BL MOTEUR_GAUCHE_AVANT
		
		BL WAIT_MESURE
		BL WAIT_MESURE
		
		BL MOTEUR_GAUCHE_ON
		BL MOTEUR_DROIT_ON
		
		; Mesure 17
		
		ldr r12,=0x06
move4
		BL MOTEUR_GAUCHE_ARRIERE
		BL MOTEUR_DROIT_AVANT
		BL WAIT_TRIOLET
		
		BL MOTEUR_GAUCHE_AVANT
		BL MOTEUR_DROIT_ARRIERE
		BL WAIT_TRIOLET
		
		subs r12,#1
		bne move4
		
		BL MOTEUR_GAUCHE_ARRIERE
		BL MOTEUR_DROIT_ARRIERE
		BL WAIT_BLANCHE	
		
		BL MOTEUR_GAUCHE_OFF
		BL MOTEUR_DROIT_OFF 
		BL WAIT_BLANCHE
		
		
		BL MOTEUR_GAUCHE_AVANT
		BL MOTEUR_DROIT_AVANT
		BL MOTEUR_GAUCHE_ON
		BL MOTEUR_DROIT_ON
		BL WAIT_NOIRE
					

		BL MOTEUR_GAUCHE_OFF
		BL MOTEUR_DROIT_OFF
		

		BL WAIT_NOIRE
		BL WAIT_BLANCHE
		
		BL WAIT_MESURE
		
		
	; Mesure 21

		BL MOTEUR_DROIT_ON
		BL MOTEUR_GAUCHE_ON
		
		ldr r12,=0x02
move4_2
		BL MOTEUR_INIT_DROITE

		BL MOTEUR_GAUCHE_AVANT
		BL MOTEUR_DROIT_AVANT
		BL WAIT_MESURE
		
		BL MOTEUR_GAUCHE_ARRIERE
		BL MOTEUR_DROIT_ARRIERE
		BL WAIT_MESURE
		
		BL MOTEUR_INIT_GAUCHE
		
		BL MOTEUR_GAUCHE_AVANT
		BL MOTEUR_DROIT_AVANT
		BL WAIT_MESURE
		
		BL MOTEUR_GAUCHE_ARRIERE
		BL MOTEUR_DROIT_ARRIERE
		BL WAIT_MESURE
		
		subs r12,#1
		bne move4_2
		
		
	; Mesure 29
		
		ldr r12, =0x04
move5
		BL MOTEUR_INIT_DROITE
		BL MOTEUR_GAUCHE_AVANT
		BL MOTEUR_DROIT_AVANT
		BL WAIT_NOIRE
		

		BL MOTEUR_GAUCHE_ARRIERE
		BL MOTEUR_DROIT_ARRIERE
		BL WAIT_NOIRE
		
		BL MOTEUR_INIT_GAUCHE
		BL MOTEUR_GAUCHE_AVANT
		BL MOTEUR_DROIT_AVANT
		BL WAIT_NOIRE
		

		BL MOTEUR_GAUCHE_ARRIERE
		BL MOTEUR_DROIT_ARRIERE
		BL WAIT_NOIRE
		
		subs r12,#1
		bne move5


		ldr r12, =0x04
move6
		BL MOTEUR_INIT_DROITE
		BL MOTEUR_GAUCHE_AVANT
		BL MOTEUR_DROIT_AVANT
		BL WAIT_CROCHE
		

		BL MOTEUR_GAUCHE_ARRIERE
		BL MOTEUR_DROIT_ARRIERE
		BL WAIT_CROCHE
		
		BL MOTEUR_INIT_GAUCHE
		BL MOTEUR_GAUCHE_AVANT
		BL MOTEUR_DROIT_AVANT
		BL WAIT_CROCHE
		

		BL MOTEUR_GAUCHE_ARRIERE
		BL MOTEUR_DROIT_ARRIERE
		BL WAIT_CROCHE
		
		subs r12,#1
		bne move6


		ldr r12, =0x05
move7
		BL MOTEUR_INIT_DROITE
		BL MOTEUR_GAUCHE_AVANT
		BL MOTEUR_DROIT_AVANT
		BL WAIT_DCROCHE
		
		BL MOTEUR_GAUCHE_ARRIERE
		BL MOTEUR_DROIT_ARRIERE
		BL WAIT_DCROCHE
		
		BL MOTEUR_INIT_GAUCHE
		BL MOTEUR_GAUCHE_AVANT
		BL MOTEUR_DROIT_AVANT
		BL WAIT_DCROCHE

		BL MOTEUR_GAUCHE_ARRIERE
		BL MOTEUR_DROIT_ARRIERE
		BL WAIT_DCROCHE
		
		subs r12,#1
		bne move7

		BL MOTEUR_GAUCHE_OFF
		BL MOTEUR_DROIT_OFF
		
		BL WAIT_BLANCHE
		
		BL WAIT_NOIRE

		
		BL MOTEUR_GAUCHE_ON
		BL MOTEUR_DROIT_ON
		
		BL PARTIE2 ; On demarre la seconde partie a l'aide du deuxieme fichier .s

FIN
		BL MOTEUR_GAUCHE_OFF
		BL MOTEUR_DROIT_OFF
		
		BL MOTEUR_INIT_RAPIDE
		
		b Switch_attente
		

WAIT_MESURE	ldr r1, =0XA58000 ; Duree correspondant à 1 mesure en 4/4 à 118BPM
wait3	subs r1, #1
        bne wait3
		BX	LR
		
WAIT_BLANCHE ldr r1, =0x52C000 ; Duree correspondant à 1 blanche à 118BPM
wait8	subs r1, #1
        bne wait8
		BX	LR
		
WAIT_NOIRE	ldr r1, =0x296000 ; Duree correspondant à 1 noire à 118BPM
wait4	subs r1, #1
        bne wait4
		BX	LR

WAIT_CROCHE	ldr r1, =0x14B000 ; Duree correspondant à 1 croche à 118BPM
wait5	subs r1, #1
        bne wait5
		BX	LR
		
WAIT_DCROCHE	ldr r1, =0xA5800 ; Duree correspondant à 1 double-croche à 118BPM
wait6	subs r1, #1
        bne wait6
		BX	LR	
		
WAIT_TCROCHE	ldr r1, =0x52C00 ; Duree correspondant à 1 triple-croche à 118BPM
wait9	subs r1, #1
        bne wait9
		BX	LR		

WAIT_TRIOLET	ldr r1, =0xDCAAA ; Duree correspondant à 1 triolet à 118BPM
wait7	subs r1, #1
        bne wait7
		BX	LR	


        END
			
			
