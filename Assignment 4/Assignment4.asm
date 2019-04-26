TITLE SortingRandomIntegers     (Assignment4.asm)

; Author: Parker Howell
; Course / Project ID      CS271 Assignment 4            
; Date: 7-30-16
; Description: 

INCLUDE Irvine32.inc

MIN = 10       ; smallest user entered amount of composite numbers to display
MAX = 200      ; largest user entered amount of composite numbers to display
LO = 100       ; lowest value to be generated
HI = 999       ; highest value to be generated
PERLINE = 10   ; amount of numbers to print per line


.data

userRands  DWORD  ?             ; user entered amount of random number to fill array with
array      DWORD  MAX DUP (?)   ; array to hold the randomly generated numbers

intro      BYTE     "Hello, and welcome to Parker Howell's assignment 4, random integer sorting program!", 0
instruct   BYTE     "How many random values would you like to generate? (The numbers will be between 100-999)",0dh,0ah
           BYTE     "[10 - 200]: ", 0
bigNum     BYTE     "You entered a number that is too large.", 0
smallNum   BYTE     "You entered a number that is too small.", 0
reEnter    BYTE     "Please enter a number between 10 and 200: ", 0
ArrayMsg1  BYTE     "The random array looks like: ", 0
ArrayMsg2  BYTE     "The sorted array looks like: ", 0
median     BYTE     "The median is: ", 0
bye        BYTE     "Yay for sorting!   Bye!", 0


.code
main PROC

     call   Clrscr             ; clears the screen
     call   Randomize          ; seed the random num generator
     call   introduction       ; introduces program
     call   getUserData        ; gets and validates user data
                               
     push   OFFSET  array      ; add array pointer to stack
     push   userRands          ; add array size to stack
     call   fillArray          ; fills the array

     push   OFFSET  array      ; add array pointer to stack
     push   userRands          ; add array size to stack
     push   OFFSET  ArrayMsg1  ; add Msg pointer to stack
     call   printArray         ; prints the unsorted array

     push   OFFSET  array      ; add array pointer to stack
     push   userRands          ; add array size to stack
     call   sortArray          ; sorts the array    
     
     push   OFFSET  array      ; add array pointer to stack
     push   userRands          ; add array size to stack
     push   OFFSET  ArrayMsg2  ; add Msg pointer to stack     
     call   printArray         ; prints the sorted array

     push   OFFSET  array     ; add array pointer to stack
     push   userRands         ; add array size to stack
     call dispMedian          ; finds and prints the median value

     call farewell          ; say goodbye

	exit	; exit to operating system
main ENDP


;************************************************************************
; procedures below 
;************************************************************************

;************************************************************************
introduction PROC
; Procedure to introduce the program and author.
; receives: none
; returns: none
; preconditions: none
; registers changed: edx
;************************************************************************
     mov       edx, OFFSET intro         ; prints intro to console
     call      WriteString
     call      CrLf
     ret
introduction ENDP




;************************************************************************
getUserData PROC
; Procedure to prompt the user to enter a number between 10-200. calls validation
; procedure to ensure entered number is within range.
; receives: none
; returns: none
; preconditions: none
; registers changed: edx
;************************************************************************
     mov       edx, OFFSET instruct   ; prints instruct to console
     call      WriteString
     
     push      OFFSET userRands       ; to store the validated user entered value
     call      validation             ; validate that userDate is in range
     ret
getUserData ENDP




;************************************************************************
validation PROC
; Procedure to validate user entered number of random numbers to generate
; receives: address of userRands pushed on stack
; returns: a valid number in userRands within the range of MIN and MAX
; preconditions: the user has been asked to enter a value
; registers changed: ebp, ebx, eax, edx
;************************************************************************
     push      ebp            ; save old ebp
     mov       ebp,esp
     mov       ebx, [ebp + 8]  ; store address of userRands in ebx

     Validate:      call      ReadDec      ; read user input
                    
                    cmp       eax, MIN     ; if user value is less than MIN
                    jl        TooSmall     ; jump to TooSmall

                    cmp       eax, MAX     ; if user value is larger than MAX
                    jg        TooBig       ; jump to TooBig

                    jmp       GoodNum      ; otherwise the value is within range
                                           ; continue with program

     ; if the user value was too small
     TooSmall:      call      CrLf
                    mov       edx, OFFSET smallNum   ; tell the user the number was too small
                    call      WriteString
                    call      CrLf
                    jmp       RePrompt               ; jump to RePrompt to ask user to enter another num

     ; if the user value was too big
     TooBig:        call      CrLf
                    mov       edx, OFFSET bigNum     ; tell the user the number was too big
                    call      WriteString
                    call      CrLf                   ; falls through to RePrompt

     ; ask user to enter another number
     RePrompt:      mov       edx, OFFSET reEnter    ; ask the user to re-enter an new number
                    call      WriteString
                    jmp       Validate               ; jump to top to have user reenter another number

     ; if the user value was within range
     GoodNum:                ; carry on with the program
     
     mov       [ebx], eax    ; save validated value in userRands 
     call      CrLf          ; formatting

     pop ebp                 ; restore ebp
     ret 4
validation ENDP




;************************************************************************
fillArray PROC
; Procedure to fill the array with userRands random numbers
; receives: address of array pushed on stack
;           address of userRands pushed on stack
; returns: array is filled with userRands amount of values between MIN and MAX
; preconditions: above 2 valid arguments are on the stack
; registers changed: ebp, esi, ecx, ebx, eax
;************************************************************************
     push      ebp       ; save old ebp
     mov       ebp, esp  
     mov       esi, [ebp + 12]     ; esi points to array
     mov       ecx, [ebp + 8]      ; set loop counter with userRands

     mov       ebx, HI       ; prepare a base range for randomrange call  
     sub       ebx, LO       ; sub the lower range limit
     inc       ebx           ; add one        base range = hi - lo + 1
                             ; this sets the base range at (0 - 899) 
fill:
     mov       eax, ebx      ; put the base range into eax
     call      RandomRange   ; generate a random number within base range
     add       eax, LO       ; add LO limit to give range between (100 - 999)

     mov       [esi], eax    ; add the value to the array 
     add       esi, 4        ; move to next array element

     loop      fill

     pop       ebp
     ret       8
fillArray ENDP




;************************************************************************
printArray PROC
; Procedure to print the values in the array to the console 
; receives: address of array pushed on stack
;           address of userRands pushed on stack
;           address of ArrayMsg1 pushed on stack
; returns: prints contents of array to console 
; preconditions: above 3 valid arguments are pushed on stack
; registers changed: ebp, esi, ecx, edx, ebx, eax
;************************************************************************
     push      ebp              ; save old ebp
     mov       ebp, esp
     mov       esi, [ebp + 16]  ; esi points to array
     mov       ecx, [ebp + 12]  ; ecx holds array userRands - array size
     mov       edx, [ebp + 8]   ; edx points to ArrayMsg(1 or 2)
     mov       ebx, 0           ; initialize a counter

     call      WriteString      ; prints ArrayMsg to console
     call      CrLf             ; formatting
     call      CrLf


printElement:                 ; printing loop
     mov       eax, [esi]     ; get current element of array
     call      WriteDec       

     mov       al, 9          ; align the colums 9 = tab
     call      writeChar

     inc       ebx            ; track how many elements are printed
     cmp       ebx, PERLINE   ; test if we need a new line
     jl        nextEle        ; jump if we dont need a new line
     
     call      CrLf           ; else we set console to next line 
     mov       ebx, 0         ; and reset ebx counter     

nextEle:
     add       esi, 4         ; go to next element of array
     loop      printElement
     
     call      CrLf           ; formatting
     call      CrLf

     pop       ebp            ; restore ebp
     ret       12
printArray ENDP




;************************************************************************
sortArray PROC
; Procedure to sort the values in the array in descending order
; receives: address of array pushed on stack
;           address of userRands pushed on stack
; returns: values in array are sorted in descending order
; preconditions: above 2 valid arguments are on the stack
; registers changed: ebp, ecx, esi, eax
; reference: The loop is a bubble sort referenced from textbook (Kip 
;            Irvine - Assembly language for x86 processors) page 375
;************************************************************************
     push      ebp              ; save old ebp
     mov       ebp, esp  
     mov       ecx, [ebp + 8]   ; set loop counter with userRands
     dec       ecx              ; so we dont go out of bounds

outerLoop:
     push      ecx               ; save outer loop count
     mov       esi, [ebp + 12]   ; esi points to array

innerLoop:
     mov       eax, [esi]      ; get first array value
     cmp       eax, [esi + 4]  ; compare it the the next value
     jae       nextTwo         ; if first value is larger or equal then dont exchange

     mov       eax, esi        ; else mov address of array into eax
     push      eax             ; push the address of smaller value
     add       eax, 4
     push      eax             ; and the address of the larger one
     call      exchange

nextTwo:
     add       esi, 4         ; move to the next element in array
     Loop      innerLoop      ; check adjacent elements for whole array

     pop       ecx            ; restore outerloop count
     Loop      outerLoop      ; do it again but 1 less each time

     pop       ebp            ; restore ebp
     ret       8
sortArray ENDP




;************************************************************************
exchange PROC
; Procedure to swap two values
; receives: address of smaller value pushed on stack
;           address of larger value pushed on stack
; returns: the values are swapped
; preconditions: above 2 valid arguments are on the stack
; registers changed: ebp, eax, ebx, edx, edi
;************************************************************************
     push      ebp              ; save old ebp
     mov       ebp, esp
     mov       eax, [ebp + 12]  ; get the address of smaller value
     mov       ebx, [ebp + 8]   ; get the address of larger value
     mov       edx, [eax]       ; put smaller value in edx
     mov       edi, [ebx]       ; put larger value in edi
     mov       [eax], edi       ; put larger val in smaller mem location
     mov       [ebx], edx       ; put smaller val in larger mem location

     pop       ebp       ; restore ebp
     ret       8
exchange ENDP




;************************************************************************
dispMedian PROC
; Procedure to find and print the median value of the sorted array. If 
; userRands is even, the two elements closest to the center are averaged 
; and remainders are rounded up. 
; receives: address of array pushed on stack
;           address of userRands pushed on stack
; returns: prints the median value of the passed in array. 
; preconditions: above 2 valid arguments are on the stack
; registers changed: ebp, esi, eax, edx, ecx, ebx, 
;************************************************************************
     push      ebp       ; save old ebp
     mov       ebp, esp  
     mov       esi, [ebp + 12]     ; esi points to array
     mov       eax, [ebp + 8]      ; set eax to userRands
     
     mov       edx, 0              ; prepare to divide
     mov       ecx, 2              ; set divisor
     div       ecx                 ; EDX:EAX / ECX
     cmp       edx, 0              ; test if there is a remainder
     jne       oddElements         ; if yes there are an odd amount of elements

     ; even amount of elements - need to average 2 center values
     mov       ebx, 4              ; size of DWORD
     mul       ebx                 ; EAX * EBX for offset of larger element
     mov       ecx, [esi + eax]    ; move median value into ecx
     sub       eax, 4              ; offset now points to smaller element
     mov       ebx, [esi + eax]    ; move median value into ebx
     add       ebx, ecx            ; add two center elements
     
     mov       eax, ebx            ; prepare for div
     mov       edx, 0              
     mov       ebx, 2              ; set divisor
     div       ebx                 ; average - EDX:EAX / EBX

     cmp       edx, 0              ; check for remainder
     je        noRem               ; if theres no remainder

     inc       eax                 ; otherwise round up

noRem:    
     jmp       printMedi

     ; just find center element
oddElements:
     mov       ebx, 4              ; size of DWORD
     mul       ebx                 ; EAX * EBX for offset 
     mov       ebx, [esi + eax]    ; move median value into ebx
     mov       eax, ebx            ; move it to EAX for WriteDec
     

printMedi:
     mov       edx, OFFSET  median  ; print median string
     call      Writestring
     call      WriteDec             ; print median value
     call      CrLf                 ; formatting
     call      CrLf

     pop       ebp
     ret       8
dispMedian ENDP




;************************************************************************
farewell PROC
; Procedure to say goodbye
; receives: none
; returns: prints bye message to console
; preconditions: none
; registers changed: edx
;************************************************************************
     mov       edx, OFFSET bye
     call      WriteString
     call      CrLf
     call      CrLf

     ret
farewell ENDP



END main
