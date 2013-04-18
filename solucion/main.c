#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "tree.h"

tree* crear_arbol_ints() {
    tree* raiz;
    tree* nodo_60;
    raiz = tree_create_int(10);
    tree_add_child(raiz,    tree_create_int(7));
    tree_add_child(raiz,    nodo_60 = tree_create_int(60));
    tree_add_child(nodo_60, tree_create_int(18));
    tree_add_child(nodo_60, tree_create_int(12));
    return raiz;
}

tree* crear_arbol_doubles() {
    tree* raiz;
    tree* nodo_271;
    tree* nodo_161;
    raiz = tree_create_double(3.14);
    tree_add_child(raiz,        nodo_271 = tree_create_double(271));
    tree_add_child(nodo_271,    tree_create_double(1.41));
    tree_add_child(raiz,        nodo_161 = tree_create_double(161));
    tree_add_child(nodo_161,    tree_create_double(12));
    return raiz;
}

tree* nuevo_arbol_string(char* string) {
    char* copia = malloc(strlen(string) + 1);
    strcpy(copia, string);
    return tree_create_string(copia);
}

tree* crear_arbol_strings() {
    tree* raiz;
    tree* zaraza;
    tree* grrrr;
    raiz = nuevo_arbol_string("brmm");
    tree_add_child(raiz,    zaraza = nuevo_arbol_string("zaraza"));
    tree_add_child(zaraza,  nuevo_arbol_string("yyyy..."));
    tree_add_child(raiz,    grrrr = nuevo_arbol_string("grrrr"));
    tree_add_child(grrrr,   nuevo_arbol_string("zarlanga"));
    return raiz;
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

    tree_print(arbol_10,      "Árbol con entero 10",       "/dev/stdout");
    tree_print(arbol_ints_1,  "Árbol de ints pruneado",    "/dev/stdout");
    tree_print(arbol_ints_2,  "Árbol de ints mergeado",    "/dev/stdout");
    tree_print(arbol_doubles, "Árbol de doubles pruneado", "/dev/stdout");
    tree_print(arbol_strings, "Árbol de strings mergeado", "/dev/stdout");

    tree_deep_delete(arbol_10);
    tree_deep_delete(arbol_ints_1);
    tree_deep_delete(arbol_ints_2);
    tree_deep_delete(arbol_doubles);
    tree_deep_delete(arbol_strings);

    return 0;
}