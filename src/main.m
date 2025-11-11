__attribute__((constructor))
static void init_tweak(void);

__attribute__((visibility("default")))
void LoadFunction(void *gum_interceptor);