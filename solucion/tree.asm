extern malloc
extern free
extern fopen
extern fprintf
extern fclose


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
    mov rsi, rax
    mov qword [rsi + OFFSET_CHILDREN], NULL
    mov [rsi + OFFSET_VALUE], r12
    mov [rsi + OFFSET_TYPE], r13

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

    mov rsi, ENUM_INT
    sub rsp, 8
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

    mov rsi, ENUM_DOUBLE
    sub rsp, 8
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

    mov rsi, ENUM_STRING
    sub rsp, 8
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
    push r14
    push r15
    sub rsp, 8

    ; Guardo el puntero al árbol
    mov r12, rdi

    ; Me aseguro que el árbol no sea nulo
    cmp r12, NULL
    je fin_delete

    ; Recorro los nodos
    mov rsi, r12
    mov r13, [rsi + OFFSET_CHILDREN]

ciclo_nodos:
    ; Termino el ciclo cuando llego al último nodo
    cmp r13, NULL
    je fin_ciclo_nodos

    ; Destruyo el árbol del nodo
    mov rsi, r13
    mov rdi, [rsi + OFFSET_ELEMENT]
    call tree_deep_delete

    ; Guardo el puntero al nodo siguiente
    ; y destruyo el nodo actual
    mov rdi, r13
    mov rsi, r13
    mov r13, [rsi + OFFSET_NEXT]
    call free

    jmp ciclo_nodos

fin_ciclo_nodos:
    ; Si el tipo es String, libero la memoria
    mov rsi, r12
    cmp qword [rsi + OFFSET_TYPE], ENUM_STRING
    jne liberar_arbol

    mov rdi, [rsi + OFFSET_VALUE]
    call free

liberar_arbol:
    mov rdi, r12
    call free

fin_delete:
    add rsp, 8
    pop r15
    pop r14
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
    push rbx
    push r12
    push r13
    push r14
    push r15

    ; Guardo los parámetros
    mov r12, rdi    ; self
    mov r13, rsi    ; child

    ; Armo el nuevo nodo
    mov rdi, TAM_LIST_NODE
    sub rsp, 8
    call malloc
    add rsp, 8
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
    pop rbx
    pop rbp
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ~ void tree_print(tree *self, char* extra, char *archivo)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tree_print:
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
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
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
    mov rbx, [r12 + OFFSET_VALUE]
    mov xmm0, 0
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

;; ~ auxiliar
;; ~ int tree_children_count(tree *self)
;tree_children_count:
;   ret
;
;; ~ auxiliar
;; ~ retorna un puntero al puntero final (el que apunta a null)
;;list_node_p* tree_last_children_pointer(tree *self)
;tree_last_children_pointer:
;   ret
;
;; ~ auxiliar
;; ~ void tree_print_value_at_level(tree* self, FILE *file, int level)
;tree_print_value_at_level:
;   ret
;
;; ~ auxiliar
;; ~ void tree_print_level(tree *self, FILE *file, int level)
;tree_print_level:
;   ret
;
;; ~ void tree_print(tree *self, char* extra, char *archivo)
;tree_print:
;   ret
;
;; ~ auxiliar
;; ~ void list_node_deep_delete(list_node **node_pointer)
;list_node_deep_delete:
;   ret
;
;
;; ~ void tree_prune(tree *self, tree_bool_method method)
;tree_prune:
;   ret
;
;; ~ auxiliar
;; ~ void tree_shallow_delete(tree *self)
;tree_shallow_delete:
;   ret
;
;
;; ~ auxiliar
;; ~ void list_node_shallow_delete(list_node **node_pointer)
;list_node_shallow_delete:
;   ret
;
;
;; ~ auxiliar
;; ~ void merge(tree *parent, list_node **node_pointer, tree_value_method value_method)
;merge:
;   ret
;
;
;; ~ tree* tree_merge(tree *self, tree_bool_method test_method, tree_value_method value_method)
;tree_merge:
;   ret
;
;; ~ boolean es_bisiesto(tree *t);
;es_bisiesto:
;   ret
;
;
;; ~ boolean es_mayor_que_sesenta(tree *t);
;es_mayor_que_sesenta:
;   ret
;
;
;; ~ boolean tiene_vocales(tree *t);
;tiene_vocales:
;   ret
;
;
;; ~ tree_value sumar(tree* padre, tree *hijo);
;sumar:
;   ret
;
;
;; ~ tree_value multiplicar(tree* padre, tree *hijo);
;multiplicar:
;   ret
;
;
;; ~ tree_value intercalar(tree* padre, tree *hijo);
;intercalar:
;   ret
;
;
;
;