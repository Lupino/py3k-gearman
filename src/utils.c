#include "utils.h"
#include <signal.h>

gearman_task_st * _gearman_execute(gearman_client_st *client,
        const char *func_name, size_t func_name_len,
        const char *unique, size_t unique_len,
        const char * workload, size_t workload_len){
    gearman_argument_t value = gearman_argument_make(0, 0, workload,
            workload_len);
    return gearman_execute(client, func_name, func_name_len, unique, unique_len,
            NULL, &value, NULL);
}

void init_signal(){
    signal(SIGINT, sigint_handler);
}

void sigint_handler(int sig) {
    exit(0);
}
