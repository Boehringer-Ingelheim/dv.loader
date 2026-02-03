#include <stdint.h> // uint32_t
#include <stdlib.h> // NULL, qsort

#define R_NO_REMAP
#define STRICT_R_HEADERS

#include <R.h>
#include <Rinternals.h>

typedef struct{
  SEXP value;
  int order;
  int position_in_hash;
} ValueOrderPosition;

static int compare_value_and_order(const void *vop1_, const void *vop2_){
  ValueOrderPosition *vop1 = (ValueOrderPosition *)vop1_;
  ValueOrderPosition *vop2 = (ValueOrderPosition *)vop2_;
  char *v1 = (char *)R_CHAR(vop1->value);
  char *v2 = (char *)R_CHAR(vop2->value);
  int res = strcmp(v1, v2);
  return res;
}

static ValueOrderPosition *g_vop = 0;
static int g_vop_allocated_count = 0;

static uint32_t *g_hash_table = 0;
static int g_hash_table_allocated_count = 0;

static SEXP character_to_factor(SEXP v){
  int prot = 0;
  
  int count = LENGTH(v);
  int hash_table_entry_count = 256;
  while(hash_table_entry_count < 2*count) hash_table_entry_count *= 2;

  if(g_hash_table_allocated_count < hash_table_entry_count){
    g_hash_table = (uint32_t *)realloc(g_hash_table, hash_table_entry_count * sizeof(uint32_t));
    g_hash_table_allocated_count = hash_table_entry_count;
  }
  memset(g_hash_table, 0, hash_table_entry_count * sizeof(uint32_t));

  // worst-case we use all the positions 
  if(count < hash_table_entry_count){
    g_vop = (ValueOrderPosition *)realloc(g_vop, count * sizeof(ValueOrderPosition));
    g_vop_allocated_count = count;
  }
  // NOTE: g_vop does not need clearing

  int unique_value_count = 0;
  
  SEXP res = PROTECT(Rf_allocVector(INTSXP, count)); prot += 1;
  int *resp = INTEGER(res);

  SEXP *pv = (SEXP*)STRING_PTR(v);
  SEXP *cur_pv = pv;

  int mask = hash_table_entry_count-1;
  for(int i = 0; i < count; i += 1, cur_pv += 1){
    // We assume the string pointers are uniformly distributed, discard the lower three bytes
    // (which should be set to zero due to 64-bit alignment) and mask to get in the range of our table
    int id = (((uintptr_t)*cur_pv)>>3) & mask; // 3: alignment to 8 bytes
    
    while(g_hash_table[id]){
      if(pv[g_hash_table[id]-1] == *cur_pv) goto after;
      id = (id+1) & mask;
    }

    g_vop[unique_value_count].value = *cur_pv;
    g_vop[unique_value_count].order = unique_value_count;
    g_vop[unique_value_count].position_in_hash = id;
    g_hash_table[id] = i+1;
    unique_value_count += 1;
    after:
    resp[i] = id;
  }

  qsort(g_vop, unique_value_count, sizeof(g_vop[0]), compare_value_and_order);
 
  int NA_is_present = 0;
  for(int i = 0, v = 1; i < unique_value_count; i += 1, v += 1){
    g_hash_table[g_vop[i].position_in_hash] = v;

    if(g_vop[i].value == R_NaString){
      NA_is_present = 1;
      g_hash_table[g_vop[i].position_in_hash] = R_NaInt;
      v -= 1;
    }
  }

  for(int i = 0; i < count; i += 1) resp[i] = g_hash_table[resp[i]];

  /* Attach levels */ {
    SEXP levels = PROTECT(Rf_allocVector(STRSXP, unique_value_count-NA_is_present)); prot += 1;

    for(int i = 0, j = 0; i < unique_value_count-NA_is_present; i+=1, j+=1){
      if(g_vop[j].value == R_NaString){
        i -= 1;
        continue;
      }
      SET_STRING_ELT(levels, i, g_vop[j].value);
    }

    Rf_setAttrib(res, R_LevelsSymbol, levels);
    SEXP classV = PROTECT(Rf_allocVector(STRSXP,1)); prot += 1;
    SET_STRING_ELT(classV, 0, Rf_mkChar("factor"));
    Rf_classgets(res, classV);
  }
  
  UNPROTECT(prot);
  return res;
}

static R_CallMethodDef CallEntries[] = {
  {"character_to_factor", (DL_FUNC) &character_to_factor, 1},
  {NULL, NULL, 0}
};

void R_init_dv_loader(DllInfo *dll){
  R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
  R_useDynamicSymbols(dll, FALSE);
}
