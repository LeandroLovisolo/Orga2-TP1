#include <cstdlib>
#include <cstdio>
#include <cerrno>
#include <cstring>

#include <vector>
#include <queue>

using namespace std;

#include "tree.h"

#define CANTIDAD_DE_TESTS 50
#define CANTIDAD_DE_ARBOLES_POR_TEST 10
#define CANTIDAD_DE_NODOS_POR_ARBOL 500
#define CANTIDAD_DE_OPERACIONES 5
#define MAX_STRING_LENGTH 20


#ifdef DEBUG
#define DLOG(...) printf("DEBUG:: "); printf(__VA_ARGS__);
#else
#define DLOG(...)
#endif



char* getParam(char *needle, char *haystack[], int count) {
	int i = 0;
	for (i = 0; i < count; i ++) {
		if (strcmp(needle, haystack[i]) == 0) {
			if (i < count -1) {
				return haystack[i+1];
			}	
		}
	}
	return 0;	
}


int isParam(char * needle, char* haystack[], int count) {
	int i = 0;
	for (i = 0; i < count; i ++) {
		if (strcmp(needle, haystack[i]) == 0) {
			return 1;
		}
	}
	return 0;	
}

int parsecommand(char *comando, tree *t, char *dirbuf, char *dir);

void showusage(char* filename);

tree     *arboles[CANTIDAD_DE_ARBOLES_POR_TEST];
tree_type tipos[CANTIDAD_DE_ARBOLES_POR_TEST];


queue<tree*> free_trees[CANTIDAD_DE_ARBOLES_POR_TEST];

void push_free_tree(int num_arbol, tree *t)
{
	if (arboles[num_arbol] == NULL) 
		arboles[num_arbol] = t;
	else
		free_trees[num_arbol].push(t);
}

tree* pop_free_tree(int num_arbol)
{
	tree *result = free_trees[num_arbol].front();
	while(result == 0)
		{}

	free_trees[num_arbol].pop();
	return result;
}

vector<tree*> tree_ids_cache[CANTIDAD_DE_ARBOLES_POR_TEST];

void add_subtree_to_cache(int num_arbol, tree *t)
{
	tree_ids_cache[num_arbol].push_back(t);
	
	list_node *node = t->children;
	while (node != NULL)
	{
		add_subtree_to_cache(num_arbol, node->element);
		node = node->next;
	}
}

void rebuild_tree_ids_cache(int num_arbol, tree *t)
{
	tree_ids_cache[num_arbol].clear();
	add_subtree_to_cache(num_arbol, t);
}

tree *tree_from_id(int num_arbol, int id)
{
	vector<tree *> &cache = tree_ids_cache[num_arbol];
	return cache[id % cache.size()];
}

int main (int argc, char *argv[]) {
	  
	if (false) {
		char z[] = "zaraza.txt";
		char y[] = "";

		FILE *g = fopen(z, "w");
		fclose(g);

		tree *trees[6];
		for (int i = 0; i < 6; i++)
			trees[i] = tree_create_double(23.0*i);
		trees[5]->value.d = 15.0;
		tree_add_child(trees[0], trees[5]);

		for (int i = 0; i < 4; i++)
			tree_add_child(trees[i], trees[i+1]);

		tree_print(trees[0], y, z);
		tree_prune(trees[0], &es_mayor_que_sesenta);
		tree_print(trees[0], y, z);

		tree_deep_delete(trees[0]);
	}

//	listaMap( NULL, (void* (*) (void*))	 tomar_primeros_10 );
		  
//	listaFilter( NULL,	(enum boolean_e (*)(void*))	 es_largo_mayor_10);
	
  
	char * testfilename = getParam((char*)"-f", (char**)argv, argc);

	if (! isParam((char*)"-f", argv, argc) && ! isParam((char*)"-t", argv, argc)) {
		DLOG("No hay parametros\n");
		showusage(argv[0]);
		return 0;
	}


	freopen(testfilename,"r",stdin);
	char outputfile[100];
	sprintf(outputfile,"%s.out",testfilename);

	bool generarCatedra = false;
//	generarCatedra = true;
	if (generarCatedra) {
		char testnum[] = "xx"; testnum[0] = testfilename[13]; testnum[1] = testfilename[14];
		sprintf(outputfile,"../tests/test%s.catedra.out",testnum);
	}

	FILE *f = fopen(outputfile, "w");
	fclose(f);

	char command[50];
	
	for (int i = 0; i < CANTIDAD_DE_ARBOLES_POR_TEST; i++)
	{
		int tipo_valor;
		scanf("TIPO %d ",&tipo_valor);
		tipos[i]=(tree_type)tipo_valor;
	}


	int num_arbol;

	while(~scanf("%s",command)){
		switch(command[0]){
		  case 'C': {

			scanf("%d",&num_arbol);

			tree_value valor;
			tree_type tipo = tipos[num_arbol];
			if(tipo == Integer) scanf("%d ", &valor.i);
			if(tipo == Double) scanf("%lf ", &valor.d);
			if(tipo == String) {
				valor.s = (char*)malloc(MAX_STRING_LENGTH);
				scanf("%s", valor.s);
			}
				
			tree *nuevo = tree_create(valor, tipo);
			push_free_tree(num_arbol, nuevo);
			rebuild_tree_ids_cache(num_arbol, arboles[num_arbol]);
			break; }
		  case 'A': {
			int id_padre;
			scanf("%d %d",&num_arbol, &id_padre); 
			tree *hijo = pop_free_tree(num_arbol);
			tree *padre = tree_from_id(num_arbol, id_padre);
			tree_add_child(padre, hijo); 
			rebuild_tree_ids_cache(num_arbol, arboles[num_arbol]);
			break; }
		  case 'I': {
			char extra[200];
			scanf("%d %s", &num_arbol, extra);
			char extra2[200];
			sprintf(extra2, "arbol %d, %s", num_arbol, extra);
			tree_print(arboles[num_arbol], extra2, outputfile);
			break; }
		  case 'D':
			scanf("%d",&num_arbol);
			tree_deep_delete(arboles[num_arbol]);
			break;

		  case 'P': { 
			scanf("%d",&num_arbol); int tipo = tipos[num_arbol];
			if(tipo == Integer) tree_prune(arboles[num_arbol], &es_bisiesto);
			if(tipo == Double)  tree_prune(arboles[num_arbol], &es_mayor_que_sesenta);
			if(tipo == String)  tree_prune(arboles[num_arbol], &tiene_vocales);
			rebuild_tree_ids_cache(num_arbol, arboles[num_arbol]);
			break; }
		  case 'M': {
			scanf("%d",&num_arbol); int tipo = tipos[num_arbol];
			if(tipo == Integer) tree_merge(arboles[num_arbol], &es_bisiesto, &sumar);
			if(tipo == Double)  tree_merge(arboles[num_arbol], &es_mayor_que_sesenta, &multiplicar);
			if(tipo == String)  tree_merge(arboles[num_arbol], &tiene_vocales, &intercalar);
			rebuild_tree_ids_cache(num_arbol, arboles[num_arbol]);
			break; }
			
		}
	}

	return 0;
}

void printerrno() {
	printf("%#x\n", errno);
}

void showusage(char* filename) {
	printf("Uso: %s -f ARCHIVO\n", filename);
	printf("\n");
	printf("Utiliza ARCHIVO como un conjunto de acciones a seguir. Cada linea del archivo de texto representa una accion a realizar. El archivo de salida se realizara en el mismo directorio con el mismo nombre que la entrada y extension .out.\n");
	printf("\n");
	printf("Las acciones posibles son:\n");
	printf("CREAR <ID> <TIPO>\n");
	printf("AGREGAR <ID> <DATO>\n");
	printf("DESTRUIR <ID>\n");
	printf("FILTRAR <ID>\n");
	printf("MAP <ID>\n");
	printf("IMPRIMIR <ID>\n");
	printf("\n");
  printf("<ID> corresponde al identificador de la lista. Un mismo archivo puede crear muchas listas distintas, cada una con tipo distinto.\n");
  printf("<TIPO> corresponde a un valor del 1 si es una lista de INT, 2 si es una lista de FLOAT y 3 si es una lista de strings.\n");
  printf("<DATO> corresponde al elemento ingresado. No se realiza un chequeo de que dato sea del tipo de la lista, por lo que es responsabilidad del que crea ARCHIVO que los datos sean del tipo de la lista.\n");
	printf("\n");
  printf("Para ver ejemplos, se puden consultar los archivos *.in provistos por la cátedra.\n");
}
