cdef extern from "libgearman/gearman.h":
    ctypedef struct gearman_task_st:
        pass
    ctypedef struct gearman_client_st:
        pass
    ctypedef struct gearman_job_st:
        pass
    ctypedef struct gearman_worker_st:
        pass
    ctypedef struct gearman_allocator_t:
        pass
    ctypedef struct gearman_task_attr_t:
        pass
    ctypedef struct gearman_result_st:
        pass
    ctypedef struct gearman_string_t:
        pass
    ctypedef struct gearman_argument_t:
        pass
    ctypedef struct gearman_status_t:
        pass
    ctypedef enum gearman_return_t:
        pass
    ctypedef struct gearman_function_t:
        pass
    # ctypedef struct gearman_string_t:
    #     const char *c_str
    #     const size_t size
    # ctypedef struct gearman_argument_t:
    #     gearman_string_t name
    #     gearman_string_t value

    # gearman_worker_st
    gearman_worker_st *gearman_worker_create(gearman_worker_st *worker)
    gearman_return_t gearman_worker_add_server(gearman_worker_st *worker,
            const char *host, int port)
    gearman_return_t gearman_worker_add_servers(gearman_worker_st *,
            const char *)
    void gearman_worker_remove_servers(gearman_worker_st *)
    void gearman_worker_free(gearman_worker_st *worker)
    gearman_return_t gearman_worker_work(gearman_worker_st *worker)
    gearman_return_t gearman_worker_set_identifier(gearman_worker_st *worker,
            const char *id, size_t id_size)
    # gearman_client_st
    gearman_client_st *gearman_client_create(gearman_client_st *)
    void gearman_client_free(gearman_client_st *)
    gearman_return_t gearman_client_add_server(gearman_client_st *,
            const char *, int)
    gearman_return_t gearman_client_add_servers(gearman_client_st *,
            const char *)
    void gearman_client_remove_servers(gearman_client_st *)
    gearman_return_t gearman_client_set_identifier(gearman_client_st *client,
            const char *id, size_t id_size)
    const char *gearman_client_error(const gearman_client_st *client)
    # gearman_job_st
    void gearman_job_free(gearman_job_st *job)
    gearman_return_t gearman_job_send_data(gearman_job_st *job,
            const char *data, size_t data_size)
    gearman_return_t gearman_job_send_warning(gearman_job_st *job,
            const char *warning, size_t warning_size)
    gearman_return_t gearman_job_send_status(gearman_job_st *job,
            int numerator, int denominator)
    gearman_return_t gearman_job_send_complete(gearman_job_st *job,
            const char *result, size_t result_size)
    # gearman_return_t gearman_job_send_exception(gearman_job_st *job,
    #         const char *exception, size_t exception_size)
    gearman_return_t gearman_job_send_fail(gearman_job_st *job)
    const char *gearman_job_handle(const gearman_job_st *job)
    const char *gearman_job_function_name(const gearman_job_st *job)
    const char *gearman_job_unique(const gearman_job_st *job)
    const void *gearman_job_workload(const gearman_job_st *job)
    size_t gearman_job_workload_size(const gearman_job_st *job)
    void *gearman_job_take_workload(gearman_job_st *job, size_t *data_size)
    # gearman_job_st *gearman_worker_grab_job(gearman_worker_st *worker,
    #         gearman_job_st *job, gearman_return_t *ret_ptr)
    # function
    gearman_function_t gearman_function_create(
            gearman_return_t (gearman_job_st *, void *))
    gearman_return_t gearman_worker_define_function(gearman_worker_st *worker,
            const char *function_name, const size_t function_name_length,
            const gearman_function_t function, const int timeout,
            void *context)

    ctypedef char gearman_job_handle_t[64]
    gearman_return_t gearman_client_do_background(gearman_client_st *client,
          const char *function_name,
          const char *unique,
          const void *workload,
          size_t workload_size,
          gearman_job_handle_t job_handle)

    gearman_return_t gearman_client_do_low_background(gearman_client_st *client,
          const char *function_name,
          const char *unique,
          const void *workload,
          size_t workload_size,
          gearman_job_handle_t job_handle)

    gearman_return_t gearman_client_do_high_background(gearman_client_st *client,
          const char *function_name,
          const char *unique,
          const void *workload,
          size_t workload_size,
          gearman_job_handle_t job_handle)

    void *gearman_client_do(gearman_client_st *client,
         const char *function_name,
         const char *unique,
         const void *workload, size_t workload_size,
         size_t *result_size,
         gearman_return_t *ret_ptr)

    void *gearman_client_do_high(gearman_client_st *client,
         const char *function_name,
         const char *unique,
         const void *workload, size_t workload_size,
         size_t *result_size,
         gearman_return_t *ret_ptr)

    void *gearman_client_do_low(gearman_client_st *client,
         const char *function_name,
         const char *unique,
         const void *workload, size_t workload_size,
         size_t *result_size,
         gearman_return_t *ret_ptr)

    # gearman_return_t
    const char *gearman_strerror(gearman_return_t rc)
    int gearman_success(gearman_return_t rc)
    int gearman_failed(gearman_return_t rc)
    int gearman_continue(gearman_return_t rc)

    # gearman_task_st
    # gearman_task_st *gearman_execute(gearman_client_st *client,
    #           const char *function_name, size_t function_name_length,
    #           const char *unique, size_t unique_length,
    #           gearman_task_attr_t *workload,
    #           gearman_argument_t *arguments,
    #           void *context)

    # gearman_argument_t gearman_argument_make(
    #         const char *name, const size_t name_length,
    #         const char *value, const size_t value_size)
    gearman_return_t gearman_task_return(const gearman_task_st *task)
    gearman_result_st *gearman_task_result(gearman_task_st *task)
    const char *gearman_result_value(const gearman_result_st *self)
    size_t gearman_result_size(const gearman_result_st *self)

    void gearman_task_free(gearman_task_st *task)
    void *gearman_task_context(const gearman_task_st *task)
    void gearman_task_set_context(gearman_task_st *task, void *context)
    const char *gearman_task_function_name(const gearman_task_st *task)
    const char *gearman_task_unique(const gearman_task_st *task)
    const char *gearman_task_job_handle(const gearman_task_st *task)
    int gearman_task_is_known(const gearman_task_st *task)
    int gearman_task_is_running(const gearman_task_st *task)
    int gearman_task_numerator(const gearman_task_st *task)
    int gearman_task_denominator(const gearman_task_st *task)
    void gearman_task_give_workload(gearman_task_st *task, const void *workload, size_t workload_size)
    size_t gearman_task_send_workload(gearman_task_st *task, const void *workload, size_t workload_size, gearman_return_t *ret_ptr)
    const void *gearman_task_data(const gearman_task_st *task)
    size_t gearman_task_data_size(const gearman_task_st *task)
    void *gearman_task_take_data(gearman_task_st *task, size_t *data_size)
    size_t gearman_task_recv_data(gearman_task_st *task, void *data, size_t data_size, gearman_return_t *ret_ptr)
    const char *gearman_task_error(const gearman_task_st *task)

    # gearman_task_st *gearman_client_add_task(gearman_client_st *client,
    #         gearman_task_st *task,
    #         void *context,
    #         const char *function_name,
    #         const char *unique,
    #         const char *workload,
    #         size_t workload_size,
    #         gearman_return_t *ret_ptr)

    # gearman_task_st *gearman_client_add_task_low(gearman_client_st *client,
    #         gearman_task_st *task,
    #         void *context,
    #         const char *function_name,
    #         const char *unique,
    #         const void *workload,
    #         size_t workload_size,
    #         gearman_return_t *ret_ptr)

    # gearman_task_st *gearman_client_add_task_high(gearman_client_st *client,
    #         gearman_task_st *task,
    #         void *context,
    #         const char *function_name,
    #         const char *unique,
    #         const void *workload,
    #         size_t workload_size,
    #         gearman_return_t *ret_ptr)

    # gearman_task_st *gearman_client_add_task_background(gearman_client_st *client,
    #         gearman_task_st *task,
    #         void *context,
    #         const char *function_name,
    #         const char *unique,
    #         const void *workload,
    #         size_t workload_size,
    #         gearman_return_t *ret_ptr)

    # gearman_task_st *gearman_client_add_task_low_background(gearman_client_st *client,
    #         gearman_task_st *task,
    #         void *context,
    #         const char *function_name,
    #         const char *unique,
    #         const void *workload,
    #         size_t workload_size,
    #         gearman_return_t *ret_ptr)

    # gearman_task_st *gearman_client_add_task_high_background(gearman_client_st *client,
    #         gearman_task_st *task,
    #         void *context,
    #         const char *function_name,
    #         const char *unique,
    #         const void *workload,
    #         size_t workload_size,
    #         gearman_return_t *ret_ptr)

    # gearman_return_t gearman_client_run_tasks(gearman_client_st *client)

cdef extern from "utils.h":
    gearman_task_st * _gearman_execute(gearman_client_st *client,
            const char *func_name, size_t func_name_len,
            const char *unique, size_t unique_len,
            const char * workload, size_t workload_len)

    void init_signal()
