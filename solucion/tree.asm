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


; cambiar las xxx por su valor correspondiente

; %define TAM_TREE xxx
; %define TAM_NODO xxx
; %define TAM_dato_int xxx
; %define TAM_dato_double xxx
; %define TAM_puntero xxx
; %define TAM_value xxx
; %define offset_children xxx
; %define offset_value    xxx
; %define offset_tipo     xxx
; %define offset_element xxx
; %define offset_next    xxx

; %define ENUM_int xxx
; %define ENUM_double xxx
; %define ENUM_string xxx

%define NULL 0

section .data


section .text
; ~ tree* tree_create(tree_value value, tree_type type)
tree_create:
	ret

; ~ tree* tree_create_int(int value)
tree_create_int:
	ret

; ~ tree* tree_create_double(double value)
tree_create_double:
	ret

; ~ tree* tree_create_string(char *str)
tree_create_string:
	ret

; ~ void tree_deep_delete(tree *self)
tree_deep_delete:
	ret

; ~ auxiliar
; ~ int tree_children_count(tree *self)
tree_children_count:
	ret

; ~ auxiliar
; ~ retorna un puntero al puntero final (el que apunta a null)
;list_node_p* tree_last_children_pointer(tree *self)
tree_last_children_pointer:
	ret

; ~ void tree_add_child(tree *self, tree *child)
tree_add_child:
	ret

; ~ auxiliar
; ~ void tree_print_value_at_level(tree* self, FILE *file, int level)
tree_print_value_at_level:
	ret

; ~ auxiliar
; ~ void tree_print_level(tree *self, FILE *file, int level)
tree_print_level:
	ret

; ~ void tree_print(tree *self, char* extra, char *archivo)
tree_print:
	ret

; ~ auxiliar
; ~ void list_node_deep_delete(list_node **node_pointer)
list_node_deep_delete:
	ret


; ~ void tree_prune(tree *self, tree_bool_method method)
tree_prune:
	ret

; ~ auxiliar
; ~ void tree_shallow_delete(tree *self)
tree_shallow_delete:
	ret


; ~ auxiliar
; ~ void list_node_shallow_delete(list_node **node_pointer)
list_node_shallow_delete:
	ret


; ~ auxiliar
; ~ void merge(tree *parent, list_node **node_pointer, tree_value_method value_method)
merge:
	ret


; ~ tree* tree_merge(tree *self, tree_bool_method test_method, tree_value_method value_method)
tree_merge:
	ret

; ~ boolean es_bisiesto(tree *t);
es_bisiesto:
	ret


; ~ boolean es_mayor_que_sesenta(tree *t);
es_mayor_que_sesenta:
	ret


; ~ boolean tiene_vocales(tree *t);
tiene_vocales:
	ret


; ~ tree_value sumar(tree* padre, tree *hijo);
sumar:
	ret


; ~ tree_value multiplicar(tree* padre, tree *hijo);
multiplicar:
	ret


; ~ tree_value intercalar(tree* padre, tree *hijo);
intercalar:
	ret



