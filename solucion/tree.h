
#ifndef _TREE_H_
#define _TREE_H_

#ifdef __cplusplus
extern "C" {
#endif

typedef enum boolean
{
	False = 0,
	True = 1
} boolean;

typedef enum tree_type {
	Integer,
	Double,
	String
} tree_type;

typedef union tree_value {
		int i;
		double d;
		char *s;
} __attribute__((__packed__)) tree_value;

tree_value ival(int i);
tree_value dval(double d);
tree_value sval(char *s);

struct list_node;

typedef struct tree {
	
	struct list_node *children;
	tree_value value;
	tree_type  type;
	
} __attribute__((__packed__)) tree;

typedef struct list_node {
	tree *element;
	struct list_node *next;
} __attribute__((__packed__)) list_node;

typedef list_node* list_node_p;

typedef boolean    (*tree_bool_method)(tree* self);
typedef tree_value (*tree_value_method)(tree *parent, tree *child);

tree* tree_create(tree_value value, tree_type type);

tree* tree_create_int(int value);
tree* tree_create_double(double value);
tree* tree_create_string(char *str);

void  tree_deep_delete(tree *self);


boolean tree_has_childs(tree *self);
void  tree_add_child(tree *self, tree *element);

tree* tree_children_at(tree *self, int position);

void  tree_prune(tree *self, tree_bool_method method);
tree* tree_merge(tree *self, tree_bool_method test_method, tree_value_method value_method);

void tree_print(tree *self, char *extra, char *archivo);


boolean es_bisiesto(tree *t);
boolean es_mayor_que_sesenta(tree *t);
boolean tiene_vocales(tree *t);

tree_value sumar(tree* padre, tree *hijo);
tree_value multiplicar(tree* padre, tree *hijo);
tree_value intercalar(tree* padre, tree *hijo);


#ifdef __cplusplus
}
#endif

#endif /// _TREE_H_


