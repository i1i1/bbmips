#include <stdlib.h>
#include <assert.h>
#include <string.h>

#include "vector.h"


int
vector_init(vector *v, size_t size, void *(*real)(void *, size_t))
{
	void *data;

	assert(v);
	assert(size);

	if (!real)
		real = realloc;

	data = real(NULL, size * VECTOR_START_MAXNMEMB);

	if (!data)
		return VECTOR_MEM_ERR;

	v->nmemb = 0;
	v->maxnmemb = VECTOR_START_MAXNMEMB;
	v->size = size;
	v->data = data;
	v->realloc = real;

	return VECTOR_OK;
}

void
vector_free(vector *v)
{
	assert(v);

	v->realloc(v->data, 0);
}

void
vector_initdata(vector *v, void *arr, size_t nmemb, size_t size,
		void *(*real)(void *, size_t))
{
	assert(v);
	assert(arr);
	assert(nmemb);
	assert(size);

	if (!(real))
		real = realloc;

	v->data = arr;
	v->nmemb = nmemb;
	v->maxnmemb = nmemb;
	v->size = size;
	v->realloc = real;
}

int
vector_nmemb(const vector *v)
{
	assert(v);

	return v->nmemb;
}

void *
vector_data(const vector *v)
{
	assert(v);
	assert(v->data);

	return v->data;
}

void
vector_set(vector *v, size_t idx, const void *val)
{
	void *p;

	assert(v);
	assert(v->data);
	assert(val);

	assert(idx < v->nmemb);

	p = (void *)((char *)v->data + idx * v->size);

	memcpy(p, val, v->size);
}

const void *
vector_get(const vector *v, size_t idx)
{
	assert(v);
	assert(v->data);

	assert(idx < v->nmemb);

	return (void *)((const char *)v->data + idx * v->size);
}

/* Add element to vector so: v[idx] = val */
int
vector_add(vector *v, size_t idx, const void *val)
{
	void *data;
	size_t nmemb;
	size_t i;

	assert(v);
	assert(v->data);
	assert(val);
	assert(idx <= v->nmemb);

	if (v->nmemb == v->maxnmemb) {
		nmemb = (size_t)(v->maxnmemb * VECTOR_MAXNMEMB_GROWTH);
		data = v->realloc(v->data, nmemb * v->size);

		if (!data)
			return VECTOR_MEM_ERR;

		v->data = data;
		v->maxnmemb = nmemb;
	}

	v->nmemb++;

	for (i = idx; i < v->nmemb - 1; i++)
		/* v[i] = v[i + 1] */
		vector_set(v, i + 1, vector_get(v, i));

	vector_set(v, idx, val);

	return VECTOR_OK;
}

void
vector_remove(vector *v, size_t idx)
{
	size_t i;

	assert(v);
	assert(v->nmemb);
	assert(idx < v->nmemb);

	for (i = idx + 1; i < v->nmemb; i++)
		/* v[i - 1] = v[i] */
		vector_set(v, i - 1, vector_get(v, i));

	v->nmemb--;
}

int
vector_push(vector *v, const void *val)
{
	assert(v);

	return vector_add(v, v->nmemb, val);
}

void
vector_pop(vector *v)
{
	assert(v);
	assert(v->nmemb);

	vector_remove(v, v->nmemb - 1);
}

