print macro string

    mov ah, 09h
    lea dx, string
    int 21h

ENDM

clear macro

    mov ax, 0600h
    mov cx, 0000h
    mov dx, 184Fh
    int 10h

ENDM

backup macro

    mov axB, ax
    mov bxB, bx
    mov cxB, cx
    mov dxB, dx

ENDM

clearR macro

    xor ax, ax
    xor bx, bx
    xor cx, cx
    xor dx, dx

ENDM

restarR macro

    mov ax, axB
    mov bx, bxB
    mov cx, cxB
    mov dx, dxB

    xor axB, 0000h
    xor bxB, 0000h
    xor cxB, 0000h
    xor dxB, 0000h

ENDM

operator macro op

    cmp op, 2bh
    je SUM
    cmp op, 2dh
    je SUS
    cmp op, 2ah
    je MULT
    cmp op, 2fh
    je DIVI

ENDM


inputOptions macro option

    LOCAL SHOW_ENTER
    LOCAL HIDDE_ENTER
    LOCAL OUT_MACRO

    cmp option, 31h
    je SHOW_ENTER
    jne HIDDE_ENTER

    SHOW_ENTER:
        mov ah, 01h 
        int 21h
        
        jmp OUT_MACRO

    HIDDE_ENTER:
        mov ah, 08h
        int 21h

    OUT_MACRO:

ENDM

getInput macro buffer, buffer2, ind

    LOCAL CHARACTER, OUT_INPUT

    xor si, si
    xor di, di


    CHARACTER: 

        inputOptions flagTrue

        cmp al, 0dh
        je OUT_INPUT

        mov di, ind

        mov buffer[si], al
        mov buffer2[di], al
        inc si
        inc ind
        jmp CHARACTER

    OUT_INPUT:
        mov buffer[si], 24h

ENDM

getNumber macro buffer

    LOCAL NUMBER, SIGN, NEGATIVE, NUMRESULT, OUT_NUMBER

    xor ax, ax
    xor bx, bx
    xor si, si
    xor cx, cx

    mov bx, 0ah

    NUMBER:
        mov cl, buffer[si]

        cmp cl, 2dh             ;Compara si en el buffer en la posición es el signo "-"
        je SIGN

        cmp cl, 30h
        jb NEGATIVE

        cmp cl, 39h
        ja NEGATIVE

        sub cl, 48
        mul bx                  ;Multiplica lo que hay en ax por 10

        add ax, cx              ;Suma lo que hay en ax con cx para obtener el número final

        inc si
        jmp NUMBER

    SIGN:
        mov isNegative, 1
        inc si
        jmp NUMBER

    NEGATIVE:
        cmp isNegative, 1
        je NUMRESULT
        JMP OUT_NUMBER
    
    NUMRESULT:
        neg ax
        mov isNegative, 0

    OUT_NUMBER:

ENDM


getBuffer macro buffer

    LOCAL NUMBER, SIGN, NEGATIVE, FILL_BUFFR , OUT_BUFFER

    xor bx, bx
    xor si, si
    xor cx, cx
    xor dx, dx

    mov bx, 0ah 

    NUMBER:
        
        test ax, ax
        js NEGATIVE

        div bx                  ;ax -> resultado; dx -> residuo
        
        add dx, 48
        inc cx
        push dx

        cmp ax, 00h
        je FILL_BUFFR

        xor dx, dx
        jmp NUMBER
        
    FILL_BUFFR:
        pop ax
        mov buffer[si], al
        inc si
        loop FILL_BUFFR

        jmp OUT_BUFFER

    SIGN: 
        mov buffer[si], 2dh
        inc si
        jmp NUMBER

    NEGATIVE:
        neg ax
        jmp SIGN

    OUT_BUFFER:
        mov buffer[si], 24h


ENDM

copy macro bufferO, bufferD

    Local COPYB, EXIT

    xor si, si
    xor cx, cx

    COPYB: 

        cmp bufferO[si], 24h
        je EXIT

        mov cl, bufferO[si]
        mov bufferD[si], cl
        inc si

        jmp COPYB


    EXIT:
    mov bufferD[si], 24h

ENDM


operations struct

    id db ?, '$'
    operation db 0ah, 45 Dup('$'), 0
    result db 0ah, 10 dup('$'), 0
    status db 00h

operations ends

.model small

.stack 100h


.data

headerMsg db 0ah, 'UNIVERSIDAD DE SAN CARLOS DE GUATEMALA', 0ah, 'FACULTADAD DE INGENIERIA', 0ah, 'ESCUELA DE CIENCIAS Y SISTEMAS', 0ah, 'ARQUITECTURA DE COMPUTADORAS Y ENSAMBLADORES 1 A', 0ah, 'SECCIN B', 0ah, 'PRIMER SEMESTRE 2021', 0ah , 'Elian Saul Estrada Urbina', 0ah, '201806838', 0ah, 'Primera Practica Assembler', '$'
menu db 0ah, 0ah, '===========Principal Menu===========', 0ah, '1. File Upload', 0ah, '2. Calculator Mode', 0ah, '3. Factorial', 0ah, '4. Create Report', 0ah, '5. Exit', 0ah, 0ah, 'Please Choose Option: ','$'
entrada db 'hola','$'
resultC dw ?, 0
calculator db 0ah, 0ah, '===========Calculator Mode===========', '$'
varInputNum db 0ah, 0ah, 'Enter a Number: ', '$'
varInputOp db 0ah, 0ah, 'Enter a Operator: ', '$'
varInputOF db 0ah, 0ah, 'Enter a Operator or ; to End: ', '$'
outResult db 0ah, 0ah, 'The Result is: ', '$'
outFacR db ' != ', '$'
outMul db ' * ', '$'
outEq db ' = ', '$'
operatorF db 0ah, 0ah, 'Operations: ', '$'

index dw 0000h, 0

op1 operations<>
op2 operations<>
op3 operations<>
op4 operations<>
op5 operations<>
op6 operations<>
op7 operations<>
op8 operations<>
op9 operations<>
op10 operations<>

bufferNumber1 db 5 Dup('$'), 0
bufferNumber2 db 5 dup('$'), 0
bufferResult db 10 dup('$'), 0
bufferOperation db 45 dup('$'), 0

varFactorial db 0ah, 0ah, '===========Factorial===========', '$'
menuError db 0ah, 'Please Choose a Valid Option.', '$'
keyPress db 0ah, 0ah, 'Press any key to continue...','$'
flagTrue db 31h, '$'
flagFalse db 30h, '$'
isNegative db ?, '$'

axB dw ?, 0
bxB dw ?, 0
cxB dw ?, 0
dxB dw ?, 0

.code

    main proc

        mov dx, @DATA
        mov ds, dx
        ;mov es, dx

        HEDAR:  
            

        MENU2: 
            clear

            print op1.status

            

            print headerMsg
            print menu

            inputOptions flagTrue

            cmp al, 31h
            je FILE_UPLOAD
            cmp al, 32h
            je CALCULATOR_MODE
            cmp al, 33h
            je FACTORIAL 
            cmp al, 34h
            je CREATE_REPORT
            cmp al, 35h
            je EXIT
            jne ERROR_MENU


        FILE_UPLOAD:
            print entrada
            jmp EXIT

        CALCULATOR_MODE: 
            
            clearR
            ;xor si, si
            print calculator

            print varInputNum
            getInput bufferNumber1, bufferOperation, index
            getNumber bufferNumber1
            mov resultC, ax

            print varInputOp
            inputOptions flagTrue

            operator al


            CALCULATOR_LOOP: 
                print varInputOF
                inputOptions flagTrue

                cmp al, 3bh
                je RCALC

                operator al

            SUM:

                mov si, index
                mov bufferOperation[si], 2bh
                inc index

                print varInputNum
                getInput bufferNumber2, bufferOperation, index
                getNumber bufferNumber2

                add resultC, ax
                jmp CALCULATOR_LOOP

            SUS:

                mov si, index
                mov bufferOperation[si], 2dh
                inc index
                print varInputNum
                getInput bufferNumber2, bufferOperation, index
                getNumber bufferNumber2

                sub resultC, ax
                jmp CALCULATOR_LOOP

            MULT:
                
                mov si, index
                mov bufferOperation[si], 2ah
                inc index

                print varInputNum
                getInput bufferNumber2, bufferOperation, index
                getNumber bufferNumber2

                imul resultC
                mov resultC, ax
                jmp CALCULATOR_LOOP

                
            DIVI:

                mov si, index
                mov bufferOperation[si], 2fh
                inc index

                print varInputNum
                getInput bufferNumber2 bufferOperation, index
                getNumber bufferNumber2

                mov bx, ax
                mov ax, resultC

                idiv bx
                mov resultC, ax
                jmp CALCULATOR_LOOP
                
            ;jmp EXIT

        RCALC: 
            mov ax, resultC
            getBuffer bufferResult
            print outResult
            print bufferResult
            
            mov si, index
            mov bufferOperation[si], 24h

            mov index, 0000h

            copy bufferOperation, op1.operation

            print op1.operation

            mov resultC, 0000h

            print keyPress
            inputOptions flagFalse

            clear
            jmp MENU2

        FACTORIAL:
            ;clear 

            clearR

            print varFactorial

            print varInputNum
            getInput bufferNumber1, bufferOperation, index
            getNumber bufferNumber1

            mov bx, ax


            backup

            print operatorF             ;Operators:

            mov ax, axB

            getBuffer bufferResult
            print bufferResult
            print outFacR

            clearR
            restarR
            ;mov bufferResult, 0000h

            ;mov ax, bx

        OPFAC: 
            ;5 
            cmp bx, 00h
            je RFAC0
            cmp bx, 01h
            je RFAC

            ;mov axB, ax                 ;axB = ax -> axB = 3, 6

            backup

            mov ax, bx

            getBuffer bufferResult
            print bufferResult          ; print 3
            print outMul                ; print *

            clearR
            restarR 

            sub bx, 01h          ; bx = bx - 1 -> bx = 2, 1
            mul bx               ; ax = ax * bx -> ax = 3 * 2 -> ax = 6, 6
            mov resultC, ax      ; resultC = ax -> resultC = 6, 6


            jmp OPFAC

        RFAC0:
            
            mov ax, 01h

            getBuffer bufferResult
            print bufferResult

            print outResult
            print bufferResult

            print keyPress
            inputOptions flagFalse

            jmp MENU2

        RFAC:
            ;mov ax, resultC

            mov ax, bx              ; ax = bx -> ax = 1

            cmp resultC, 0000h
            je RFAC1

            getBuffer bufferResult
            print bufferResult

            print outEq

            xor ax, ax

            mov ax, resultC         ; ax = resultC -> ax = 6

            getBuffer bufferResult
            print bufferResult

            mov resultC, 0000h

            print outResult
            print bufferResult

            print keyPress
            inputOptions flagFalse

            jmp MENU2

        RFAC1: 

            getBuffer bufferResult
            print bufferResult

            print outResult
            print bufferResult

            print keyPress
            inputOptions flagFalse

            jmp MENU2

        CREATE_REPORT:
            jmp EXIT

        ERROR_MENU:
            clear
            print menuError
            print keyPress
            inputOptions flagFalse
            jmp MENU2


        EXIT:

            mov ah, 4ch
            int 21h

    main endp

end