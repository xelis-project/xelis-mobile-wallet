#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
typedef struct _Dart_Handle* Dart_Handle;

typedef struct DartCObject DartCObject;

typedef int64_t DartPort;

typedef bool (*DartPostCObjectFnType)(DartPort port_id, void *message);

typedef struct wire_KeyPair {
  const void *ptr;
} wire_KeyPair;

typedef struct DartCObject *WireSyncReturn;

void store_dart_post_cobject(DartPostCObjectFnType ptr);

Dart_Handle get_dart_object(uintptr_t ptr);

void drop_dart_object(uintptr_t ptr);

uintptr_t new_dart_opaque(Dart_Handle handle);

intptr_t init_frb_dart_api_dl(void *obj);

void wire_create_key_pair(int64_t port_);

void wire_get_address(int64_t port_, struct wire_KeyPair key_pair);

struct wire_KeyPair new_KeyPair(void);

void drop_opaque_KeyPair(const void *ptr);

const void *share_opaque_KeyPair(const void *ptr);

void free_WireSyncReturn(WireSyncReturn ptr);

static int64_t dummy_method_to_enforce_bundling(void) {
    int64_t dummy_var = 0;
    dummy_var ^= ((int64_t) (void*) wire_create_key_pair);
    dummy_var ^= ((int64_t) (void*) wire_get_address);
    dummy_var ^= ((int64_t) (void*) new_KeyPair);
    dummy_var ^= ((int64_t) (void*) drop_opaque_KeyPair);
    dummy_var ^= ((int64_t) (void*) share_opaque_KeyPair);
    dummy_var ^= ((int64_t) (void*) free_WireSyncReturn);
    dummy_var ^= ((int64_t) (void*) store_dart_post_cobject);
    dummy_var ^= ((int64_t) (void*) get_dart_object);
    dummy_var ^= ((int64_t) (void*) drop_dart_object);
    dummy_var ^= ((int64_t) (void*) new_dart_opaque);
    return dummy_var;
}
