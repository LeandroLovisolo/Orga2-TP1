#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "tree.h"

tree_value ival(int i) {
    tree_value v;
    v.i = i;
    return v;
}

tree_value dval(double d) {
    tree_value v;
    v.d = d;
    return v;
}

tree_value sval(char *s) {
    tree_value v;
    v.s = s;
    return v;
}

tree* tree_create(tree_value value, tree_type type) {
    tree* t = malloc(sizeof(tree));
    t->children = NULL;
    t->value = value;
    t->type = type;
    return t;
}

tree* tree_create_int(int value) {
    return tree_create(ival(value), Integer);
}

tree* tree_create_double(double value) {
    return tree_create(dval(value), Double);
}

tree* tree_create_string(char *str) {
    return tree_create(sval(str), String);
}

void tree_add_child(tree *self, tree *element) {
    list_node *child = malloc(sizeof(list_node));
    child->element = element;
    child->next = NULL;

    if(self->children == NULL) {
        self->children = child;
    } else {
        list_node *node = self->children;
        while(node->next != NULL) {
            node = node->next;
        }
        node->next = child;
    }
}

void tree_deep_delete(tree *self) {
    if(self == NULL) return;
    list_node* node = self->children;
    while(node != NULL) {
        tree_deep_delete(node->element);
        list_node* next = node->next;
        free(node);
        node = next;
    }
}

void tree_print_node(tree *node, int level, FILE *h) {
    if(node == NULL) return;
    if(level == 0) {
        fprintf(h, "> ");
    } else {
        for(int i = 1; i < level; i++) {
            fprintf(h, "  ");
        }
        fprintf(h, "--> ");
    }
    fprintf(h, "node: ");
    switch(node->type) {
        case Integer:
            fprintf(h, "%d\n", node->value.i);
            break;
        case Double:
            fprintf(h, "%f\n", node->value.d);
            break;
        case String:
            fprintf(h, "%s\n", node->value.s);
            break;
    }
    list_node* child = node->children;
    while(child != NULL) {
        tree_print_node(child->element, level + 1, h);
        child = child->next;
    }
}

void tree_print(tree *self, char *extra, char *archivo) {
    FILE* h = fopen(archivo, "a");
    fprintf(h, "%s\n", extra);
    tree_print_node(self, 0, h);
    fprintf(h, "--------\n");
    fclose(h);
}

void tree_prune(tree *self, tree_bool_method method) {
    list_node* prev = NULL;
    list_node* node = self->children;

    while(node != NULL) {
        if(method(node->element)) {
            list_node* next = node->next;
            tree_deep_delete(node->element);
            free(node);
            if(prev == NULL) {
                self->children = next;
            } else {
                prev->next = next;
            }
            node = next;
        } else {
            tree_prune(node->element, method);
            prev = node;
            node = node->next;
        }
    }
}

void tree_merge(tree *self, tree_bool_method test_method, tree_value_method value_method) {
    list_node* orphans = NULL;
    list_node* prev    = NULL;
    list_node* node    = self->children;
    
    while(node != NULL) {
        if(test_method(node->element)) {
            self->value = value_method(self, node->element);

            // Me guardo los hijos del nodo
            if(orphans == NULL) {
                orphans = node->element->children;
            } else {
                list_node* orphan = orphans;
                while(orphan->next != NULL) orphan = orphan->next;
                orphan->next = node->element->children;
            }

            // Elimino el nodo de la lista de hijos del árbol
            if(prev == NULL) {
                self->children = node->next;
            } else {
                prev->next = node->next;
            }

            // Elimino el nodo y su árbol
            list_node* next = node->next;
            free(node->element);
            free(node);
            node = next;
        } else {
            tree_merge(node->element, test_method, value_method);
            prev = node;
            node = node->next;            
        }
    }

    // Agrego los huérfanos al final de la lista
    if(prev == NULL) {
        self->children = orphans;
    } else {
        prev->next = orphans;
    }
}

boolean es_bisiesto(tree *t) {
    return (t->value.i % 4   == 0) && !((t->value.i % 100 == 0) && (t->value.i % 400 != 0));
    //return (t->value.i % 400 == 0) ||  ((t->value.i % 4   == 0) && (t->value.i % 100 != 0))
}

boolean es_mayor_que_sesenta(tree *t) {
    return t->value.d > 60.0;
}

boolean tiene_vocales(tree *t) {
    return strchr(t->value.s, 'a') != NULL ||
           strchr(t->value.s, 'e') != NULL ||
           strchr(t->value.s, 'i') != NULL ||
           strchr(t->value.s, 'o') != NULL ||
           strchr(t->value.s, 'u') != NULL ||
           strchr(t->value.s, 'A') != NULL ||
           strchr(t->value.s, 'E') != NULL ||
           strchr(t->value.s, 'I') != NULL ||
           strchr(t->value.s, 'O') != NULL ||
           strchr(t->value.s, 'U') != NULL;
}

tree_value sumar(tree* padre, tree *hijo) {
    tree_value v;
    v.i = padre->value.i + hijo->value.i;
    return v;
}

tree_value multiplicar(tree* padre, tree *hijo) {
    tree_value v;
    v.d = padre->value.d * hijo->value.d;
    return v;
}

tree_value intercalar(tree* padre, tree *hijo) {
    int len = strlen(padre->value.s) > strlen(hijo->value.s) ?
            strlen(padre->value.s) : strlen(hijo->value.s);
    tree_value v;
    v.s = malloc(len + 1);
    int i;
    for(i = 0; i < len; i++) {
        if(i % 2 == 0) {
            v.s[i] = i < strlen(padre->value.s) ?
                    padre->value.s[i] : hijo->value.s[i];
        } else {
            v.s[i] = i < strlen(hijo->value.s) ?
                    hijo->value.s[i] : padre->value.s[i];
        }
    }
    v.s[i] = 0;

    //free(padre->value.s);
    //free(hijo->value.s);
    return v;
}
