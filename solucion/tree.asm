extern malloc
extern free
extern fopen
extern fprintf
extern fclose
extern strchr
extern strlen


global tree_create
global tree_create_int
global tree_create_double
global tree_create_string
global tree_deep_delete
global tree_add_child
global tree_print
global tree_prune
global tree_merge

global es_bisiesto
global es_mayor_que_sesenta
global tiene_vocales

global sumar
global multiplicar
global intercalar


; tree
%define TAM_TREE        24
%define OFFSET_CHILDREN 0
%define OFFSET_VALUE    8
%define OFFSET_TYPE     16

; list_node
%define TAM_LIST_NODE   16
%define OFFSET_ELEMENT  0
%define OFFSET_NEXT     8

; tree_value
%define TAM_TREE_VALUE  8

; tree_type
%define ENUM_INT        0
%define ENUM_DOUBLE     1
%define ENUM_STRING     2

; tipos básicos
%define TAM_INT         4
%define TAM_DOUBLE      8
%define TAM_PTR         8

%define NULL 0


section .data
    tree_print_append:              DB 'a', 0
    tree_print_extra:               DB '%s', 10, 0
    tree_print_footer:              DB '--------', 10, 0
    tree_print_prefijo_cero:        DB '> node: ', 0
    tree_print_prefijo_margen:      DB '  ', 0
    tree_print_prefijo_mayor_cero:  DB '--> node: ', 0
    tree_print_node_int:            DB '%d', 10, 0
    tree_print_node_double:         DB '%f', 10, 0
    tree_print_node_string:         DB '%s', 10, 0
    sesenta:                        DQ 60.0
    vocales:                        DB 'aeiouAEIOU'


section .text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ~ tree* tree_create(tree_value value, tree_type type)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tree_create:
    push rbp
    mov rbp, rsp
    push r12
    push r13

    ; Guardo los parámetros
    mov r12, rdi    ; value
    mov r13, rsi    ; type

    ; Reservo la memoria
    mov rdi, TAM_TREE
    call malloc

    ; Completo la estructura
    mov qword [rax + OFFSET_CHILDREN], NULL
    mov [rax + OFFSET_VALUE], r12
    mov [rax + OFFSET_TYPE], r13

    pop r13
    pop r12
    pop rbp
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ~ tree* tree_create_int(int value)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tree_create_int:
    push rbp
    mov rbp, rsp
    sub rsp, 8

    mov rsi, ENUM_INT
    call tree_create

    add rsp, 8
    pop rbp
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ~ tree* tree_create_double(double value)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tree_create_double:
    push rbp
    mov rbp, rsp
    sub rsp, 8

    movq rdi, xmm0
    mov rsi, ENUM_DOUBLE
    call tree_create

    add rsp, 8
    pop rbp
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ~ tree* tree_create_string(char *str)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tree_create_string:
    push rbp
    mov rbp, rsp
    sub rsp, 8

    mov rsi, ENUM_STRING
    call tree_create

    add rsp, 8
    pop rbp
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ~ void tree_deep_delete(tree *self)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tree_deep_delete:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8

    ; Guardo el puntero al árbol
    mov r12, rdi

    ; Me aseguro que el árbol no sea nulo
    cmp r12, NULL
    je fin_delete

    ; Recorro los nodos
    mov r13, [r12 + OFFSET_CHILDREN]

ciclo_nodos:
    ; Termino el ciclo cuando llego al último nodo
    cmp r13, NULL
    je fin_ciclo_nodos

    ; Destruyo el árbol del nodo
    mov rdi, [r13 + OFFSET_ELEMENT]
    call tree_deep_delete

    ; Guardo el puntero al nodo siguiente
    ; y destruyo el nodo actual
    mov rdi, r13
    mov r13, [r13 + OFFSET_NEXT]
    call free

    jmp ciclo_nodos

fin_ciclo_nodos:
    ; Si el tipo es String, libero la memoria
    cmp qword [r12 + OFFSET_TYPE], ENUM_STRING
    jne liberar_arbol

    mov rdi, [r12 + OFFSET_VALUE]
    call free

liberar_arbol:
    mov rdi, r12
    call free

fin_delete:
    add rsp, 8
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ~ void tree_add_child(tree *self, tree *child)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tree_add_child:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15

    ; Guardo los parámetros
    mov r12, rdi    ; self
    mov r13, rsi    ; child

    ; Armo el nuevo nodo
    mov rdi, TAM_LIST_NODE
    call malloc
    mov r14, rax     ; nuevo list_node
    mov [r14 + OFFSET_ELEMENT], r13
    mov qword [r14 + OFFSET_NEXT], NULL

    ; Decido si self ya tiene hijos
    cmp qword [r12 + OFFSET_CHILDREN], NULL
    jne buscar_ultimo_hijo

    ; Agrego el nuevo nodo como primer hijo
    mov [r12 + OFFSET_CHILDREN], r14
    jmp fin_add_child

buscar_ultimo_hijo:
    ; Comienzo el ciclo en el primer hijo de self
    mov r15, [r12 + OFFSET_CHILDREN]

ciclo_ultimo_hijo:
    cmp qword [r15 + OFFSET_NEXT], NULL
    je fin_ciclo_ultimo_hijo
    mov r15, [r15 + OFFSET_NEXT]
    jmp ciclo_ultimo_hijo

fin_ciclo_ultimo_hijo:
    ; Agrego el nuevo nodo luego del último hijo de self
    mov [r15 + OFFSET_NEXT], r14

fin_add_child:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ~ void tree_print(tree *self, char* extra, char *archivo)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tree_print:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15

    ; Guardo los parámetros
    mov r12, rdi    ; self
    mov r13, rsi    ; extra
    mov r14, rdx    ; archivo

    ; Abro el archivo
    mov rdi, r14
    mov rsi, tree_print_append
    call fopen
    mov r15, rax    ; handler

    ; Imprimo mensaje extra
    mov rdi, r15
    mov rsi, tree_print_extra
    mov rdx, r13
    call fprintf

    ; Imprimo el árbol
    mov rdi, r12
    mov rsi, 0
    mov rdx, r15
    call tree_print_node

    ; Imprimo footer
    mov rdi, r15
    mov rsi, tree_print_footer
    call fprintf

    ; Cierro el archivo
    mov rdi, r15
    call fclose

fin_tree_print:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

; ~ auxiliar
; ~ void tree_print_node(tree *node, int level, FILE *h)
tree_print_node:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    ; Guardo los parámetros
    mov r12, rdi    ; node
    mov r13, rsi    ; level
    mov r14, rdx    ; handler

    ; Verifico que el árbol no sea nulo
    cmp r12, NULL
    je fin_tree_print_node

    ; Genero el prefijo
    cmp r13, 0
    jne nivel_mayor_cero

    ; Prefijo nivel cero
    mov rdi, r14        
    mov rsi, tree_print_prefijo_cero
    call fprintf
    jmp imprimir_nodo

nivel_mayor_cero:
    ; Imprimo el margen
    mov rbx, 1

ciclo_print_node:
    cmp rbx, r13
    jge fin_ciclo_print_node

    mov rdi, r14
    mov rsi, tree_print_prefijo_margen
    call fprintf

    inc rbx
    jmp ciclo_print_node

fin_ciclo_print_node:
    ; Imprimo prefijo nivel > 0
    mov rdi, r14
    mov rsi, tree_print_prefijo_mayor_cero
    call fprintf

imprimir_nodo:
    cmp dword [r12 + OFFSET_TYPE], ENUM_DOUBLE
    je formato_double

    cmp dword [r12 + OFFSET_TYPE], ENUM_STRING
    je formato_string

    ; Formato Integer
    mov rdi, r14
    mov rsi, tree_print_node_int
    mov rdx, [r12 + OFFSET_VALUE]
    jmp invocar_fprintf

formato_double:
    mov rdi, r14
    mov rsi, tree_print_node_double
    movupd xmm0, [r12 + OFFSET_VALUE]
    jmp invocar_fprintf
    
formato_string:
    mov rdi, r14
    mov rsi, tree_print_node_string
    mov rdx, [r12 + OFFSET_VALUE]   

invocar_fprintf:
    call fprintf

    ; Me paro en el primer hijo
    mov r15, [r12 + OFFSET_CHILDREN]

    ; Recorro los hijos
ciclo_imprimir_hijos:
    cmp r15, NULL
    je fin_tree_print_node

    ; Imprimo el hijo actual
    mov rdi, [r15 + OFFSET_ELEMENT]
    mov rsi, r13
    inc rsi
    mov rdx, r14
    call tree_print_node

    ; Me muevo al siguiente hijo y repito
    mov r15, [r15 + OFFSET_NEXT]
    jmp ciclo_imprimir_hijos

fin_tree_print_node:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ~ void tree_prune(tree *self, tree_bool_method method)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tree_prune:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    ; Guardo los parámetros
    mov r12, rdi    ; self
    mov r13, rsi    ; method

    ; Punteros para navegar el árbol
    mov r14, NULL                       ; nodo anterior = NULL
    mov r15, [r12 + OFFSET_CHILDREN]    ; nodo actual = primer nodo

ciclo_prune:
    ; Loopeo mientras que el nodo actual no sea nulo
    cmp r15, NULL
    je fin_prune

    ; Decido si hay que podar el nodo actual
    mov rdi, [r15 + OFFSET_ELEMENT]
    call r13
    cmp rax, 0
    je no_podar_nodo_actual

    ;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; Podar nodo actual ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Puntero al nodo siguiente
    mov rbx, [r15 + OFFSET_NEXT]

    ; Destruyo árbol del nodo actual
    mov rdi, [r15 + OFFSET_ELEMENT]
    call tree_deep_delete

    ; Libero memoria del nodo actual
    mov rdi, r15
    call free

    ; Decido si había nodo anterior
    cmp r14, NULL
    je no_habia_nodo_anterior

    ; Conecto nodo anterior con nodo siguiente
    mov [r14 + OFFSET_NEXT], rbx

    jmp fin_conectar_nodos

no_habia_nodo_anterior:
    ; Convierto el nodo siguiente en el primer hijo del árbol
    mov [r12 + OFFSET_CHILDREN], rbx

fin_conectar_nodos:
    ; Avanzo al siguiente nodo
    mov r15, rbx

    jmp ciclo_prune

no_podar_nodo_actual:

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; No podar nodo actual ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Inicio recursión sobre los hijos
    mov rdi, [r15 + OFFSET_ELEMENT]
    mov rsi, r13
    call tree_prune

    ; Avanzo al siguiente nodo
    mov r14, r15                    ; nodo anterior = nodo actual
    mov r15, [r15 + OFFSET_NEXT]    ; nodo actual = nodo siguiente

    jmp ciclo_prune

fin_prune:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ~ tree* tree_merge(tree *self, tree_bool_method test_method, tree_value_method value_method)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Variable local: puntero a lista de huérfanos
%define orphans [rbp - 48]

tree_merge:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    ; Guardo los parámetros
    mov r12, rdi    ; self
    mov r13, rsi    ; test_method
    mov r14, rdx    ; value_method

    ; Punteros para navegar el árbol
    mov r15, NULL                       ; nodo anterior
    mov rbx, [r12 + OFFSET_CHILDREN]    ; nodo actual

    ; Inicializo lista de nodos huérfanos, donde voy a
    ; almacenar los hijos de todos los nodos mergeados
    mov rax, NULL
    mov orphans, rax

    ; Itero sobre los hijos del árbol
ciclo_merge:
    cmp rbx, NULL
    je fin_ciclo_merge   

    ; Decido si mergeo el nodo actual
    mov rdi, [rbx + OFFSET_ELEMENT]     ; Árbol del nodo actual
    call r13                            ; test_method
    cmp rax, 0
    je no_mergear_nodo_actual

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; Mergear nodo actual ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Obtengo el nuevo valor del nodo padre
    mov rdi, r12
    mov rsi, [rbx + OFFSET_ELEMENT]
    call r14
    mov [r12 + OFFSET_VALUE], rax

    ; Determino dónde guardo los hijos del nodo
    mov rax, orphans
    cmp rax, NULL
    je no_hay_huerfanos

    ; Los guardo al final de la lista de huérfanos
    mov rax, orphans                    ; Me paro en el primer huérfano
ciclo_huerfanos:
    cmp qword [rax + OFFSET_NEXT], NULL ; Compruebo si es el último huérfano
    je fin_ciclo_huerfanos              ; En caso afirmativo, termino el ciclo
    mov rax, [rax + OFFSET_NEXT]        ; Avanzo al siguiente huérfano
    jmp ciclo_huerfanos
fin_ciclo_huerfanos:
    mov rcx, [rbx + OFFSET_ELEMENT]     ; Obtengo árbol del nodo actual
    mov rcx, [rcx + OFFSET_CHILDREN]    ; Obtengo su lista de hijos
    mov [rax + OFFSET_NEXT], rcx        ; La agrego al final de la lista de huérfanos
    jmp podar_nodo_actual

no_hay_huerfanos:
    ; Los convierto en la nueva lista de huérfanos
    mov rax, [rbx + OFFSET_ELEMENT]     ; Obtengo el árbol del nodo actual
    mov rax, [rax + OFFSET_CHILDREN]    ; Obtengo su lista de hijos
    mov orphans, rax                    ; La convierto en la nueva lista de huérfanos

podar_nodo_actual:
    cmp r15, NULL                       ; Verifico si es el primer nodo del árbol
    je es_primer_nodo                   ; Si lo es, apunto la lista de hijos del árbol al nodo siguiente

    ; Si no lo es, conecto el elemento siguiente del nodo
    ; anterior con el elemento siguiente del nodo actual
    mov rax, [rbx + OFFSET_NEXT]        ; Obtengo el nodo siguiente al actual
    mov [r15 + OFFSET_NEXT], rax        ; Lo asigno como nodo siguiente del nodo anterior
    jmp liberar_nodo_y_arbol

es_primer_nodo:
    ; Apunto la lista de hijos del árbol al nodo siguiente
    mov rax, [rbx + OFFSET_NEXT]        ; Obtengo el nodo siguiente al actual
    mov [r12 + OFFSET_CHILDREN], rax    ; Lo asigno como primer hijo del árbol

liberar_nodo_y_arbol:
    mov rdi, [rbx + OFFSET_ELEMENT]     ; Libero el árbol del nodo actual
    call free

    mov rdi, rbx                        ; Guardo el nodo actual
    mov rbx, [rbx + OFFSET_NEXT]        ; Avanzo al siguiente nodo
    call free                           ; Libero el nodo actual
    jmp ciclo_merge                     ; Repito el ciclo

no_mergear_nodo_actual:

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; No mergear nodo actual ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Inicio recursión sobre los hijos
    mov rdi, [rbx + OFFSET_ELEMENT]     ; self
    mov rsi, r13                        ; test_method
    mov rdx, r14                        ; value_method
    call tree_merge

    ; Avanzo al siguiente nodo y repito el ciclo
    mov r15, rbx                    ; Guardo nodo actual como nodo anterior
    mov rbx, [rbx + OFFSET_NEXT]    ; Avanzo al siguiente nodo
    jmp ciclo_merge

fin_ciclo_merge:
    ; Decido dónde agrego los nodos huérfanos
    cmp r15, NULL
    je agregar_huerfanos_al_arbol

    ; Agrego los nodos huérfanos luego del último hijo
    mov rax, orphans
    mov [r15 + OFFSET_NEXT], rax

    jmp fin_tree_merge

agregar_huerfanos_al_arbol:
    ; Agrego los nodos huérfanos como hijos del árbol
    mov rax, orphans
    mov [r12 + OFFSET_CHILDREN], rax

fin_tree_merge:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ~ boolean es_bisiesto(tree *t);
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

es_bisiesto:
    push rbp
    mov rbp, rsp
    push rbx

    ; Devuelvo True si y sólo si:
    ; (año % 4 == 0) && !((año % 100 == 0) && (año % 400 != 0))

    ; Extraigo el año
    mov ebx, [rdi + OFFSET_VALUE]

    ; Computo año % 4 == 0
    xor edx, edx
    mov eax, ebx
    mov edi, 4
    div edi
    cmp edx, 0
    jne no_es_bisiesto

    ; Guardo (año % 100 == 0) en R8
    xor edx, edx
    mov eax, ebx
    mov edi, 100
    div edi
    cmp edx, 0
    je divisible_por_100
    mov r8, 0
    jmp dividir_por_400
divisible_por_100:
    mov r8, 1

    ; Guardo (año % 400 != 0) en R9
dividir_por_400:
    xor edx, edx
    mov eax, ebx
    mov edi, 400
    div edi
    cmp edx, 0
    je divisible_por_400
    mov r9, 1
    jmp computar_nand
divisible_por_400:
    mov r9, 0

    ; Computo !((año % 100 == 0) && (año % 400 != 0)) en R9
computar_nand:
    and r8, r9
    jnz no_es_bisiesto

si_es_bisiesto:
    mov rax, 1
    jmp fin_es_bisiesto

no_es_bisiesto:
    mov rax, 0

fin_es_bisiesto:
    pop rbx
    pop rbp
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ~ boolean es_mayor_que_sesenta(tree *t);
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

es_mayor_que_sesenta:
    push rbp
    mov rbp, rsp

    movsd xmm0, [rdi + OFFSET_VALUE]    ; Extraigo el double
    cmplesd xmm0, [sesenta]             ; Veo si es <= 60
    movq rax, xmm0                      ; Cargo resultado de la comparación    
    cmp rax, 0                          ; Valdrá cero sii es > 60
    je mayor_que_sesenta
    mov rax, 0
    jmp fin_es_mayor_que_sesenta

mayor_que_sesenta:
    mov rax, 1    

fin_es_mayor_que_sesenta:
    pop rbp
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ~ boolean tiene_vocales(tree *t);
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tiene_vocales:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13

    ; Extraigo la string
    mov rbx, [rdi + OFFSET_VALUE]

    ; Flag que indica si encontré vocales
    xor r12, r12

    ; Itero sobre el arreglo de vocales
    xor r13, r13                ; Me paro sobre la primer vocal
ciclo_tiene_vocales:    
    cmp r13, 10                 ; Termino el ciclo luego de recorrer
    jge fin_tiene_vocales       ; todo el array de vocales

    ; Verifico si la r13-ésima vocal está en la string
    mov rdi, rbx
    mov rsi, vocales
    add rsi, r13
    mov rsi, [rsi]
    call strchr
    cmp rax, NULL
    je no_encontro_vocal

    ; Si encontró una vocal, marco el flag y termino el ciclo
    mov r12, 1
    jmp fin_tiene_vocales

no_encontro_vocal:
    inc r13                     ; Paso a la siguiente vocal
    jmp ciclo_tiene_vocales     

fin_tiene_vocales:
    mov rax, r12
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ~ tree_value sumar(tree* padre, tree *hijo);
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sumar:
    push rbp
    mov rbp, rsp

    xor rax, rax
    mov eax, [rdi + OFFSET_VALUE]
    mov ecx, [rsi + OFFSET_VALUE]
    add eax, ecx

    pop rbp
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ~ tree_value multiplicar(tree* padre, tree *hijo);
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

multiplicar:
    push rbp
    mov rbp, rsp
    
    movsd xmm0, [rdi + OFFSET_VALUE]
    movsd xmm1, [rsi + OFFSET_VALUE]
    mulsd xmm0, xmm1
    movq rax, xmm0

    pop rbp
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ~ tree_value intercalar(tree* padre, tree *hijo);
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Variable local: longitud del string devuelto
%define longitud_nuevo_string [rbp - 48]

intercalar:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    ; Guardo los strings de los árboles
    mov r12, [rdi + OFFSET_VALUE]   ; Padre
    mov r13, [rsi + OFFSET_VALUE]   ; Hijo

    ; Obtengo longitud del string del padre
    mov rdi, r12
    call strlen
    mov r14, rax                    ; Longitud string padre

    ; Obtengo longitud del string del hijo
    mov rdi, r13
    call strlen
    mov r15, rax                    ; Longitud string hijo

    ; Guardo la longitud del string más largo
    cmp r14, r15
    jge string_padre_mayor
    mov longitud_nuevo_string, r15
    jmp reservar_string    
string_padre_mayor:
    mov longitud_nuevo_string, r14
    
reservar_string:
    ; Reservo memoria para el nuevo string
    mov rdi, longitud_nuevo_string
    inc rdi                         ; Espacio para el cero al final del string
    call malloc
    mov rbx, rax                    ; Nuevo string

    ; Itero sobre el nuevo string
    xor rcx, rcx
ciclo_string:
    cmp rcx, longitud_nuevo_string
    jge fin_ciclo_string

    ; Decido la paridad del índice actual
    xor rdx, rdx
    mov rax, rcx
    mov r8, 2
    div r8
    cmp rdx, 0
    jne indice_impar

    ;;;;;;;;;;;;;;;;;;
    ;;; Índice par ;;;
    ;;;;;;;;;;;;;;;;;;

    ; Decido si el índice es superior a la longitud del string padre
    cmp rcx, r14
    jge mayor_que_string_padre

    ; Guardo caracter en índice actual del padre
    mov dl, [r12 + rcx]
    mov [rbx + rcx], dl
    jmp siguiente_iteracion

mayor_que_string_padre:
    ; Guardo caracter en índice actual del hijo
    mov dl, [r13 + rcx]
    mov [rbx + rcx], dl
    jmp siguiente_iteracion

indice_impar:

    ;;;;;;;;;;;;;;;;;;;;
    ;;; Índice impar ;;;
    ;;;;;;;;;;;;;;;;;;;;

    ; Decido si el índice es superior a la longitud del string padre
    cmp rcx, r15
    jge mayor_que_string_hijo

    ; Guardo caracter en índice actual del hijo
    mov dl, [r13 + rcx]
    mov [rbx + rcx], dl
    jmp siguiente_iteracion

mayor_que_string_hijo:
    ; Guardo caracter en índice actual del padre
    mov dl, [r12 + rcx]
    mov [rbx + rcx], dl

siguiente_iteracion:
    inc rcx
    jmp ciclo_string

fin_ciclo_string:
    
    ; Agrego cero al final del string
    mov byte [rbx + rcx], 0

    ; Libero string del padre
    mov rdi, r12
    call free

    ; Libero string del hijo
    mov rdi, r13
    call free

    ; Devuelvo nuevo string
    mov rax, rbx

    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret