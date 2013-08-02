#include <libgearman/gearman.h>

gearman_task_st * _gearman_execute(gearman_client_st *client,
        const char *func_name, size_t func_name_len,
        const char *unique, size_t unique_len,
        const char * workload, size_t workload_len);

void sigint_handler(int);

void init_signal();
