extern malloc
extern free


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

    ; Guardo el puntero al árbol
    mov r12, rdi

    ; Me aseguro que el árbol no sea nulo
    cmp r12, NULL
    je delete_end

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
    sub rbp, 8
    call tree_deep_delete
    add rbp, 8

    ; Guardo el puntero al nodo siguiente
    ; y destruyo el nodo actual
    mov rdi, r13
    mov rsi, r13
    mov r13, [rsi + OFFSET_NEXT]
    sub rbp, 8
    call free
    add rbp, 8

    jmp ciclo_nodos

fin_ciclo_nodos:
    ; Si el tipo es String, libero la memoria
    mov rsi, r12
    cmp qword [rsi + OFFSET_TYPE], ENUM_STRING
    jne liberar_arbol

    mov rdi, [rsi + OFFSET_VALUE]
    sub rbp, 8
    call free
    add rbp, 8

liberar_arbol:
    mov rdi, r12
    sub rbp, 8
    call free
    add rbp, 8

delete_end:
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
;; ~ void tree_add_child(tree *self, tree *child)
;tree_add_child:
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