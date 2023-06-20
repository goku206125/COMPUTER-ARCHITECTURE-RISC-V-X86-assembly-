section	.text
global replace
global _replace

replace:
_replace:	
	push	ebp
	mov		ebp, esp
	mov		esi, [ebp+8]	; source
	mov		edi, [ebp+8]	; target
	xor		eax, eax		; # of lowercase
	xor		edx, edx		; temp variable
lowercase_while:
	mov		dl, [esi]
	test	dl, dl
	jz		lowecase_break
	inc		esi
	cmp		dl, 97
	jl		lowercase_while
	cmp		dl, 122
	jg		lowercase_while
	inc		eax
	jmp		lowercase_while
lowecase_break:
	and		eax, 1			; eax mod 2
	add		edi, 4
	test	eax, eax
	jnz		replace_odd		; if != 0, it's odd	
replace_even:				; otherwise even
	mov		dl, [edi]
	cmp		esi, edi
	jle		replace_done
	dec		byte [edi]		; dec by 1
	add		edi, 5
	jmp		replace_even
replace_odd:
	mov		dl, [edi]
	cmp		esi, edi
	jle		replace_done
	mov		byte [edi], '*'	; replace with '*'
	add		edi, 5
	jmp		replace_odd
replace_done:
	mov		eax, esi
	sub		eax, [ebp+8]
	pop		ebp
	ret