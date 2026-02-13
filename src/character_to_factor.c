#include <stdint.h> // int32_t
#include <stdlib.h> // NULL, qsort

#define R_NO_REMAP
#define STRICT_R_HEADERS

#include <R.h>
#include <Rinternals.h>

typedef struct{
  uint32_t index_into_g_values;
  uint32_t position_in_hash;
} ValuePosition;

typedef union{ // mutually exclusive uses
  SEXP v;
  int32_t level;
} ValueLevel;

static SEXP *g_values = 0;

static int compare_value_and_order(const void *vop1_, const void *vop2_){
  ValuePosition *vop1 = (ValuePosition *)vop1_;
  ValuePosition *vop2 = (ValuePosition *)vop2_;
  char *v1 = (char *)R_CHAR(g_values[vop1->index_into_g_values]);
  char *v2 = (char *)R_CHAR(g_values[vop2->index_into_g_values]);
  int res = strcmp(v1, v2);
  return res;
}

// We assume the string pointers are uniformly distributed. We discard the lower three bits
// (which should be set to zero due to 64-bit alignment) and mask to get in the range of the hash table
#define HASH(v, mask) (((uintptr_t)(v))>>3) & mask // assumes equidistributed values

static SEXP C_character_to_factor(SEXP v){
  int prot = 0;
  
  int v_count = LENGTH(v);

  ValueLevel *hash_table = 0; int mask = 0; {
    // Hash table with a power of two number of elements larger than the amount of input elements +
    // 1 slot reserved for the NA value
    int hash_table_entry_count = 256; {
      float hash_table_size_factor = 1.f; // TODO? Make it dependent on `v_count`
      int NA_slot = 1; 
      while(hash_table_entry_count < hash_table_size_factor*(v_count+NA_slot)) hash_table_entry_count <<= 1;
    }
    hash_table = calloc(hash_table_entry_count, sizeof(hash_table[0]));
    mask = hash_table_entry_count-1;
  }

  // Helper structure to sort the levels after we've collected them
  ValuePosition *vp = malloc(v_count*sizeof(vp[0])); // malloc because uninitialized is OK

  SEXP res = PROTECT(Rf_allocVector(INTSXP, v_count)); prot += 1;
  int *resp = INTEGER(res);

  SEXP *pv = (SEXP*)STRING_PTR(v);
  g_values = pv;
  SEXP *cur_pv = pv;

  hash_table[HASH(R_NaString, mask)].v = R_NaString; // preallocate NA to simplify the rest of the program
                                                     
  int unique_value_count = 0;
  for(int i = 0; i < v_count; i += 1, cur_pv += 1){
    int id = HASH(*cur_pv, mask);
                                               
    while(hash_table[id].v){
      if(hash_table[id].v == *cur_pv) goto after;
      id = (id+1) & mask;
    }

    vp[unique_value_count].index_into_g_values = i;
    vp[unique_value_count].position_in_hash = id;
    hash_table[id].v = *cur_pv;
    unique_value_count += 1;

    after:
    resp[i] = id; // use the result vector to cache the hash slot
  }

  // byte-wise sorting (does not take encoding or locale into account) that leaves NA as the 0th element
  qsort(vp, unique_value_count, sizeof(vp[0]), compare_value_and_order);

  /* Rewrite the hash contents to return the factor level asociated to a hashed SEXP address */ {
    // We stop using the `v` field of the hash_table _union_ and start using the `level` field instead
    hash_table[HASH(R_NaString, mask)].level = R_NaInt;
    for(int i = 0; i < unique_value_count; i += 1) hash_table[vp[i].position_in_hash].level = i+1;
  }

  // Use the cached hashes to resolve the levels
  for(int i = 0; i < v_count; i += 1) resp[i] = hash_table[resp[i]].level;

  /* Attach the level attribute to the output vector and tag it as a proper factor */ {
    SEXP levels = PROTECT(Rf_allocVector(STRSXP, unique_value_count)); prot += 1;

    for(int i = 0; i < unique_value_count; i+=1){
      SET_STRING_ELT(levels, i, g_values[vp[i].index_into_g_values]);
    }

    Rf_setAttrib(res, R_LevelsSymbol, levels);
    SEXP class = PROTECT(Rf_allocVector(STRSXP, 1)); prot += 1;
    SET_STRING_ELT(class, 0, Rf_mkChar("factor"));
    Rf_classgets(res, class);
  }

  free(vp);
  free(hash_table);
  
  UNPROTECT(prot);
  return res;
}

static R_CallMethodDef CallEntries[] = {
  {"C_character_to_factor", (DL_FUNC) &C_character_to_factor, 1},
  {NULL, NULL, 0}
};

void R_init_dv_loader(DllInfo *dll){
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
}
