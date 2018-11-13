#ifndef _VECTOR_
#define _VECTOR_

#include <stdlib.h>

#define VECTOR_START_MAXNMEMB	8
#define VECTOR_MAXNMEMB_GROWTH	1.4

enum {
	VECTOR_OK = 0,
	VECTOR_MEM_ERR = 1
};


typedef struct {
	size_t nmemb;
	size_t maxnmemb;
	size_t size;
	void *data;
	void *(*realloc)(void *, size_t);

} vector;

void vector_initdata(vector *v, void *arr, size_t nmeb, size_t size,
		void *(*real)(void *, size_t));
int vector_init(vector *v, size_t size, void *(*real)(void *, size_t));
void vector_free(vector *v);

int vector_nmemb(const vector *v);
void *vector_data(const vector *v);

void vector_set(vector *v, size_t idx, const void *val);
const void *vector_get(const vector *v, size_t idx);

int vector_push(vector *v, const void *val);
void vector_pop(vector *v);

int vector_add(vector *v, size_t idx, const void *val);
void vector_remove(vector *v, size_t idx);

#endif

