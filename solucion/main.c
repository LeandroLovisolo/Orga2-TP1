#include <stdio.h>
#include <stdlib.h>

#include "tree.h"

tree* crear_arbol_ints() {
    return NULL;
}

tree* crear_arbol_doubles() {
    return NULL;
}

tree* crear_arbol_strings() {
    return NULL;
}

int main() {
    tree* arbol_10      = tree_create_int(10);
    tree* arbol_ints_1  = crear_arbol_ints();
    tree* arbol_ints_2  = crear_arbol_ints();
    tree* arbol_doubles = crear_arbol_doubles();
    tree* arbol_strings = crear_arbol_strings();

    tree_prune(arbol_ints_1, es_bisiesto);
    tree_merge(arbol_ints_2, es_bisiesto, sumar);
    tree_prune(arbol_doubles, es_mayor_que_sesenta);
    tree_merge(arbol_strings, tiene_vocales, intercalar);

    tree_print(arbol_10,      "Árbol con entero 10",    "/dev/stdout");
    tree_print(arbol_ints_1,  "Árbol de ints pruneado", "/dev/stdout");
    tree_print(arbol_ints_2,  "Árbol de ints mergeado", "/dev/stdout");
    tree_print(arbol_doubles, "Árbol de doubles",       "/dev/stdout");
    tree_print(arbol_strings, "Árbol de strings",       "/dev/stdout");

    tree_deep_delete(arbol_10);
    tree_deep_delete(arbol_ints_1);
    tree_deep_delete(arbol_ints_2);
    tree_deep_delete(arbol_doubles);
    tree_deep_delete(arbol_strings);

    return 0;
}