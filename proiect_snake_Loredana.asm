.586
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

includelib msvcrt.lib
includelib canvas.lib
extern exit: proc
extern malloc: proc
extern calloc: proc
extern memset: proc
extern printf: proc 
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data;aici declaram date

cap DD 0
nod_sarpe struct 
	urm dd 0
	ant dd 0
	i dd 0
	j dd 0
nod_sarpe ends 
curent DD 0
precedent DD 0
coada_sarpe DD 0 
urm EQU 0
ant EQU 4
contor_x_sarpe EQU 8
contor_y_sarpe EQU 12
contor0_i dd 0 
contor1_i dd 0
contor0_j dd 0
contor1_j dd 0
directie dd 0
window_title DB "Loredana's Snake ~~~",0
area_width EQU 400
area_height EQU 480 
area DD 0;;
coord_pe_x DD 0
coord_pe_y DD 0
coord_pe_x_sarpe DD 0
coord_pe_y_sarpe DD 0
poz_sarpe DD 0
poz_mar DD 0
dim_simbol EQU 20
counter DD 0  
dim_buton_restart EQU 30
i dd 0;;
j dd 0;;
x dd 0;;
y dd 0;;
arg1 EQU 8;;;
arg2 EQU 12;;
arg3 EQU 16;;
arg4 EQU 20;;
scor DD 0;;
counter_mere DD 0;;
symbol_width EQU 10;;
symbol_height EQU 20;;
symbol_game_width EQU 20;;
symbol_game_height EQU 20;;

include digits.inc
include letters.inc
include simboluri.inc 
include matrice.inc

.code
;creez nod 
creeaza_nod proc 
	push ebp
	mov ebp, esp
	;aloc memorie
	push 20			;dimensiune struct
	call calloc
	add esp, 8		

	mov ecx, eax
	;nod_sarpe->urm = nod_sarpe 
	mov dword ptr [ecx + urm], ecx 
	;nod_sarpe->ant = nod_sarpe 
	mov dword ptr [ecx + ant], ecx 
	mov ebx, [ebp + 8]
	mov dword ptr [ecx + contor_x_sarpe], ebx
	mov ebx, [ebp + 12]
	mov dword ptr [ecx + contor_y_sarpe], ebx
	mov esp, ebp
	pop ebp
	ret 8
creeaza_nod endp

creeaza_cap_sarpe macro contor_x_sarpe, contor_y_sarpe
	push contor_y_sarpe
	push contor_x_sarpe 
	call creeaza_nod
	mov cap, eax 
endm 
;adaug nod la final de lista 

adauaga_nod_la_final PROC 		
	push ebp
	mov ebp, esp
	push nod_sarpe 
	push 1
	call calloc
	add esp, 8    
	;esi = coada_sarpe
	mov esi, eax                   
	;coada_sarpe->i = i
	mov ebx, [ebp+arg1]           
	mov dword ptr [esi+contor_x_sarpe], ebx    
	;coada_sarpe->j = j 
	mov ebx, [ebp+arg2]
	mov dword ptr [esi+contor_y_sarpe], ebx    
	;eax = coada_sarpe
	mov eax, esi                   	
	mov edi, cap 
	; ecx = ultimul element	
	mov ecx, dword ptr [edi+ant]       
	mov edx, esi
	;ultimul element -> urm = coada_sarpe 
	mov dword ptr [ecx+urm], edx     
	;coada_sarpe -> ant = ultimul element 
	mov dword ptr [edx+ant], ecx     
	;coada_sarpe->urm = cap
	mov eax, esi                   
	mov ebx, cap 
	mov dword ptr [eax+urm], ebx
	;cap->ant = coada_sarpe
	mov ecx, cap
	mov dword ptr [ecx+ant], eax    
	;returnez adresa primului element
	mov eax, cap                  
	mov esp, ebp
	pop ebp 
	ret 8		
adauaga_nod_la_final ENDP

adauaga_nod_final macro contor_x_sarpe, contor_y_sarpe
	push contor_y_sarpe
	push contor_x_sarpe 
	call adauaga_nod_la_final
	mov cap, eax 
endm 

salveaza_si_upadteaza proc
	mov eax, curent
	mov ebx, dword ptr[eax+contor_x_sarpe]
	mov contor1_i, ebx
	mov ecx, dword ptr[eax+contor_y_sarpe]
	mov contor1_j, ecx
	mov edx, contor0_i
	mov eax, curent
	mov dword ptr[eax+contor_x_sarpe], edx
	mov edx, contor0_j
	mov eax, curent
	mov dword ptr[eax+contor_y_sarpe], edx
	mov eax, contor1_i
	mov contor0_i, eax
	mov eax, contor1_j
	mov contor0_j, eax
	mov ebx, curent
	mov ecx, dword ptr[ebx+urm]
	mov curent, ecx
	cmp cap, ecx
	ret
salveaza_si_upadteaza endp

intializeaza_el_curent proc
	mov esi, cap
	mov edi, dword ptr[esi+contor_x_sarpe]
	mov contor0_i, edi
	mov edi, dword ptr[esi+contor_y_sarpe]
	mov contor0_j, edi
	mov edi, dword ptr[cap+urm]
	mov curent, edi
	ret
intializeaza_el_curent endp

directie_deplasare_sarpe proc	
	push ebp
	mov ebp, esp
	
	cmp directie, 0
	je directie_sus
	cmp directie, 1
	je directie_jos
	cmp directie, 2
	je directie_stanga
	cmp directie, 3
	je directie_dreapta
	
	directie_sus:
		call intializeaza_el_curent
		loop_sus:
			call salveaza_si_upadteaza
			je decrementeaza_x
		jmp loop_sus
			decrementeaza_x:
				mov eax, cap
				mov ebx, dword ptr[eax+contor_x_sarpe]
				sub ebx, 1
				mov dword ptr[eax+contor_x_sarpe], ebx
				jmp returneaza
		
	directie_jos:
		call intializeaza_el_curent
		loop_ios:
			call salveaza_si_upadteaza
			je incrementeaza_x
		jmp loop_ios
			incrementeaza_x:
				mov eax, cap
				mov ebx, dword ptr[eax+contor_x_sarpe]
				add ebx, 1
				mov dword ptr[eax+contor_x_sarpe], ebx
				jmp returneaza
	
	directie_stanga:
		call intializeaza_el_curent
		loop_stanga:
			call salveaza_si_upadteaza
			je decrementeaza_y
		jmp loop_stanga
			decrementeaza_y:
				mov eax, cap
				mov ebx, dword ptr[eax+contor_y_sarpe]
				sub ebx, 1
				mov dword ptr[eax+contor_y_sarpe], ebx
				jmp returneaza	
	
	directie_dreapta:
		call intializeaza_el_curent
		loop_dreapta:
			call salveaza_si_upadteaza
			je incrementeaza_y
		jmp loop_dreapta
			incrementeaza_y:
				mov eax, cap
				mov ebx, dword ptr[eax+contor_y_sarpe]
				add ebx, 1
				mov dword ptr[eax+contor_y_sarpe], ebx
				jmp returneaza	
	returneaza:
		mov eax, cap
		mov esp, ebp
		pop ebp
		ret
directie_deplasare_sarpe endp

;generez mancare
genereaza_mar macro 	
	mov eax, poz_mar
	mov matrice[eax], 0
	genereaza_locatie
	mov coord_pe_x, eax 
	genereaza_locatie
	mov coord_pe_y, eax 
	mov eax, coord_pe_y
	mov ebx, dim_simbol
	mul ebx 
	add eax, coord_pe_x  
	shl eax, 2 
	mov poz_mar, eax 
	mov matrice[eax] , 8
endm 

;generez locatie random
genereaza_locatie macro
local genereaza
genereaza:
	rdtsc
	;setez divizor
	mov edx, 0 
	div ebx
	;verific daca rezultatul este in intervalul 2 17
	cmp edx, 2
	jl genereaza
	cmp edx, 17
	jg genereaza
	;pun rezultatul in eax
	mov eax, edx
endm


line_horizontal macro x, y, lenght, color
local  bucla_line
	mov eax, y  
	mov ebx, area_width
	mul ebx 
	add eax, x ; EAX = y*area_width + x 
	shl eax, 2 ; EAX = (y*area_width + x) * 4  
	add eax, area
	mov ecx, lenght
	bucla_line :
		mov dword ptr[eax], color
		add eax, 4
	loop bucla_line
endm


line_vertical macro x, y, lenght, color
local bucla_line
	
	mov eax, y
	mov ebx, area_width
	mul ebx
	add eax, x
	shl eax, 2
	add eax, area
	mov ecx, lenght
	bucla_line :
		mov dword ptr[eax], color  ; -4*area_width
		add eax, area_width*4
	loop bucla_line
endm

draw0 proc
	push ebp
	mov ebp, esp
	pusha
	mov eax,[ebp+arg1]
	lea esi, fundal
	draw_text:
	mov ebx, symbol_game_width
	mul ebx
	mov ebx, symbol_game_height
	mul ebx
	shl eax, 2
	add esi, eax
	mov ecx, symbol_game_height
	
	bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_game_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_game_width
		
	bucla_simbol_coloane:
	cmp dword ptr [esi], 0
	je simbol_pixel_alb
	cmp dword ptr [esi], 1
	je simbol_pixel_negru	
	cmp dword ptr [esi], 2
	je simbol_pixel_verde_deschis
	cmp dword ptr [esi], 3
	je simbol_pixel_verde_inchis
	cmp dword ptr [esi], 4
	je simbol_pixel_rosu	
		
	simbol_pixel_alb:
	mov dword ptr [edi], 0ffffffh
	jmp simbol_pixel_next
	simbol_pixel_negru:
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
	simbol_pixel_verde_deschis:
	mov dword ptr [edi], 0AAFF00h
	jmp simbol_pixel_next	
	simbol_pixel_verde_inchis:
	mov dword ptr [edi], 0228B22h
	jmp simbol_pixel_next	
	simbol_pixel_rosu :
	mov dword ptr [edi], 0ff0000h
	jmp simbol_pixel_next	
		
	simbol_pixel_next:
	add esi, 4
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	dec ecx 
	cmp ecx, 0
	jne bucla_simbol_linii	
	popa
	mov esp, ebp
	pop ebp
	ret
draw0 endp 



; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y

make_text proc
	push ebp
	mov ebp, esp
	pusha
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit	
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0FFFFFFh
	jmp simbol_pixel_urm
simbol_pixel_alb:
	mov dword ptr [edi], 0
simbol_pixel_urm:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

make_symbol_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call draw0
	add esp, 16
endm



; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	cmp eax, 3   ;s-a apasat o tasta
	jz evt_tasta
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 0
	push area
	call memset
	add esp, 12
	jmp afisare_litere
	
evt_click:
;event pentru butonul de restart
;verific daca am apasat in interiorul butonului aflat intre 140 si 230 pe coordonata x
	mov eax, [ebp+arg2]
	cmp eax, 140
	jl button_fail  
	cmp eax, 230 
	jg button_fail
	
;si intre 430 si 460 pe coordonata y
	mov eax, [ebp+arg3]
	cmp eax, 430 
	jl button_fail
	mov eax, [ebp+arg3]
	cmp eax, 460 
	jg button_fail
;daca s-a apasat in interior jocul reincepe
	jmp start_joc
	
button_fail:
jmp afisare_litere
evt_tasta:	
   control_taste:	
		tasta_sus_W : 
			cmp dword ptr[ebp+arg2], 'W'
			je sus 
	
		tasta_jos_S :	
			cmp dword ptr[ebp+arg2], 'S'
			je jos 

		tasta_stanga_A :
			cmp dword ptr[ebp+arg2], 'A'
			je stanga 

		tasta_dreapta_D :
			cmp dword ptr[ebp+arg2], 'D'
			je dreapta  

	sus :
		mov directie, 0
		jmp evt_timer
	
	jos:
		mov directie, 1
		jmp evt_timer
		
	stanga:
		mov directie, 2
		jmp evt_timer
		
	dreapta:
		mov directie, 3 
		jmp evt_timer
	
	call draw
	jmp afisare_litere
	
evt_timer:
	inc counter
	
afisare_litere:
	cmp counter, 0
	je start_joc 
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;afisez counter_mere
	mov ebx, 10
	mov eax, counter_mere
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 380, 400
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 370, 400	
	
	make_text_macro 'M', area, 310, 400
	make_text_macro 'E', area, 320, 400
	make_text_macro 'R', area, 330, 400
	make_text_macro 'E', area, 340, 400
	make_symbol_macro 7, area, 350, 402
	
	line_horizontal 140, 460, dim_buton_restart, 0ffffffh
	line_horizontal 171, 460, dim_buton_restart, 0ffffffh
	line_horizontal 200, 460, dim_buton_restart, 0ffffffh
	line_horizontal 230, 460, dim_buton_restart, 0ffffffh
	line_horizontal 171, 430, dim_buton_restart, 0ffffffh
	line_horizontal 140, 430, dim_buton_restart, 0ffffffh
	line_horizontal 200, 430, dim_buton_restart, 0ffffffh
	line_horizontal 230, 430, dim_buton_restart, 0ffffffh
	line_vertical 140, 430, dim_buton_restart, 0ffffffh
	line_vertical 660, 430, dim_buton_restart, 0ffffffh
	
	make_symbol_macro 16, area, 145, 435  ;R
	make_symbol_macro 13, area, 160, 435  ;E		
	make_symbol_macro 3, area, 175, 435   ;S
	make_symbol_macro 4, area, 190, 435	  ;T
	make_symbol_macro 11, area, 205, 435  ;A
	make_symbol_macro 16, area, 220, 435  ;R
	make_symbol_macro 4, area, 235, 435	  ;T
	
	
;scor joc
	mov ebx, 10
	mov eax, scor
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 90, 400
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 80, 400
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 70, 400
	
	make_text_macro 'S', area, 10, 400
	make_text_macro 'C', area, 20, 400
	make_text_macro 'O', area, 30, 400
	make_text_macro 'R', area, 40, 400
	make_symbol_macro 7, area, 50, 402	  
	
afisare_matrice_si_sarpe :
	mov ecx, poz_sarpe 
	mov matrice[ecx], 0
	genereaza_locatie
	mov coord_pe_x_sarpe, ecx 
	genereaza_locatie
	mov coord_pe_y_sarpe, ecx 
	mov ecx, coord_pe_y_sarpe
	mov ebx, dim_simbol
	mul ebx 
	add ecx, coord_pe_x_sarpe 
	cmp ecx, poz_mar
	je afisare_matrice_si_sarpe
	shl ecx, 2
	mov poz_sarpe, ecx 
	
	;;;;design pretty
	mov matrice[0], 6
	mov matrice[76], 6
	mov matrice[1520], 6
	mov matrice[1596], 6

afiseaza_matrice :
	;initializez liniile
	mov i, 0
loop_i:
	;si coloanele
	mov j, 0  			
loop_j:	
	;calculez adresa elementului din matrice
	;folosind formula eax = (i* dim_simbol + j) *4
	mov eax, i
	imul eax, dim_simbol
	add eax, j
	shl eax, 2
	mov ecx, eax
	mov eax, i
	imul eax, dim_simbol
	push eax
	mov eax, j
	imul eax, dim_simbol
	pop ebx 
	;adresa la care pun elementul in matrice este in ecx
	make_symbol_macro matrice[ecx], area, eax, ebx
	;trec la urmatoarea coloana
	add j, 1
	cmp j,dim_simbol
	jl loop_j  
	add i, 1
	cmp i, dim_simbol
	je end_loop 
	jmp loop_i
end_loop :	

;verific daca sarpele creste sau moare pentru a-i modifica dimensiunile
	mov ebx, cap 
	mov eax, dword ptr [ebx+contor_x_sarpe]
	mov ecx, dim_simbol
	mul ecx 
	add eax, dword ptr[ebx+contor_y_sarpe]
	shl eax, 2 
	cmp matrice[eax], 8 							;mar
	je cresc_sarpe 
	cmp matrice[eax], 9 							;perete
	je rip								  	

jmp afiseaza_sarpe

cresc_sarpe : 
	;daca am ajuns in acest caz inseamna ca sarpele a mancat un mar
	;generez al mar
	genereaza_mar
	;cresc sarpele adaugand nod la final
	adauaga_nod_final 0,0
	;incrementez counter-ul pentru mere
	inc counter_mere
	
	;cresc scorul cu 20	
	add scor, 20
	cmp scor, 100
	jg bonus
jmp afiseaza_sarpe
	
bonus:
	make_text_macro 'B', area, 10, 420
	make_text_macro 'O', area, 20, 420
	make_text_macro 'N', area, 30, 420
	make_text_macro 'U', area, 40, 420
	make_text_macro 'S', area, 50, 420	
	mov eax, scor
	mov ecx, 20
	add eax, ecx
	mov scor, eax
	
jmp afiseaza_sarpe 

rip : 
	;daca am ajuns in acest caz inseamna ca sarpele a atins peretele
	;afisez mesajul GAME OVER :(
	make_symbol_macro 10, area, 120, 200  
	make_symbol_macro 11, area, 135, 200  
	make_symbol_macro 12, area, 150, 200  
	make_symbol_macro 13, area, 165, 200  

	make_symbol_macro 14, area, 185, 200 
	make_symbol_macro 15, area, 200, 200 
	make_symbol_macro 13, area, 216, 200 
	make_symbol_macro 16, area, 231, 200 
	make_symbol_macro 5, area,  250, 200 
	
	jmp final_joc
	jmp afiseaza_sarpe 


afiseaza_sarpe :
;stabilesc directia de deplasare si afisez sarpele
	 call directie_deplasare_sarpe
	 ;afisez capul
	 mov ebx, cap 
	 ;curent va pointa in continuare spre adresa primul element din lista, cap
	 mov curent, ebx 
	 ;salvez in eax indicele pe axa X a nodului curent
	 mov eax, dword ptr [ebx+contor_x_sarpe]
	 ;calculez offestul pe axa X in matrice
	 mov ecx, 20
	 mul ecx 
	 ;salvez rezultatul in ecx
	 mov ecx, eax 
	;fac acelsi lucru si pentru axa Y	 
	 mov eax, dword ptr[ebx+contor_y_sarpe]
	 mov edx, 20
	 mul edx 
	 mov edx, eax 		
	 
     make_symbol_macro 1, area, eax, ecx 
	 
	 ;pun in eax adresa urmatorului nod
	 mov eax, [ebx+urm]	
	;nodul urmator va deveni nodul curent pentru urmatoarea iteratie	 
	 mov curent, eax 

;procedez la fel pentru restul corpului 
loop_afisare_sarpe :
	mov esi, curent
	mov eax, dword ptr [esi+contor_x_sarpe]
	mov ecx, 20
	mul ecx
	mov ecx, eax
	mov eax, dword ptr [esi+contor_y_sarpe]
	mov edx, 20
	mul edx	
	mov edx, eax

	make_symbol_macro 2, area, edx, ecx
	
	mov eax, [esi+urm]
	mov curent, eax
	mov esi, cap
	cmp esi, eax
	je final
jmp loop_afisare_sarpe
	
start_joc :
	;initializez pozitia sarpelui la care sa inceapa jocul 
	creeaza_cap_sarpe 10, 10 
	adauaga_nod_final 10, 9
	genereaza_mar 
	;resetez toate counterele
	mov counter, 0
	mov scor, 0
	mov counter_mere, 0
final :
	jmp final_joc	
final_joc:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start