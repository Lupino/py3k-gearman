from gearman cimport *

init_signal()

class DoubleWorkerError(Exception):
    pass

class GearmanError(Exception):
    pass

cdef void _raise_gearman_error(gearman_return_t rc):
    if gearman_failed(rc):
        raise GearmanError(gearman_strerror(rc))

cdef class Job:
    cdef gearman_job_st *_job

    # def __cinit__(self):
    #     pass
    # def __dealloc__(self):
    #     gearman_job_free(self._job)

    @property
    def func_name(self):
        '''
         the name of the function that the job was set to execute against.
        '''
        return str(gearman_job_function_name(self._job), 'utf8')

    @property
    def workload(self):
        '''
        the job workload
        '''
        cdef const char *workload
        cdef size_t workload_size
        workload = <const char *>gearman_job_workload(self._job)
        workload_size = gearman_job_workload_size(self._job)
        return workload[:workload_size]

    @property
    def handle(self):
        '''
        the job handle
        '''
        return str(gearman_job_handle(self._job), 'utf8')

    def send(self, data):
        '''
        send(self, data)
        '''
        cdef gearman_return_t rc
        data = bytes(data, 'utf8')
        rc = gearman_job_send_data(self._job, <const char *>data, len(data))
        _raise_gearman_error(rc)

    def warning(self, warning):
        '''
        warning(self, warning)
        '''
        cdef gearman_return_t rc
        warning = bytes(warning, 'utf8')
        rc = gearman_job_send_warning(self._job, <const char *>warning,
                len(warning))
        _raise_gearman_error(rc)

    def status(self, numerator, denominator):
        '''
        status(self, numerator, denominator)
        '''
        cdef gearman_return_t rc
        rc = gearman_job_send_status(self._job, numerator, denominator)
        _raise_gearman_error(rc)


    def complete(self, result):
        '''
        complete(self, result)
        '''
        cdef gearman_return_t rc
        result = bytes(result, 'utf8')
        rc = gearman_job_send_complete(self._job, <const char *>result,
                len(result))
        _raise_gearman_error(rc)

    def fail(self):
        '''
        fail(self)
        '''
        cdef gearman_return_t rc
        rc = gearman_job_send_fail(self._job)
        _raise_gearman_error(rc)

worker_callbacks = {}

cdef gearman_return_t _func(gearman_job_st *_job, void *context):
    job = Job()
    job._job = _job
    func = worker_callbacks.get(job.func_name, None)
    if func:
        func(job)

cdef class Worker:
    cdef gearman_worker_st *_worker

    def __cinit__(self):
        self._worker = gearman_worker_create(NULL)
        if self._worker == NULL:
            raise RuntimeError()

    def __dealloc__(self):
        gearman_worker_free(self._worker)

    def add_server(self, host, port):
        '''
        add_server(self, host, port)
        add an additional gearmand server to the list of servers that the client
        will take work from.
        '''
        cdef gearman_return_t rc
        host = bytes(host, 'utf8')
        rc = gearman_worker_add_server(self._worker, host, port)
        _raise_gearman_error(rc)

    def add_servers(self, servers):
        '''
        add_servers(self, servers)
        takes a list of gearmand servers that will be parsed to provide servers
        for the client. The format for this is SERVER[:PORT][,SERVER[:PORT]]...
        '''
        cdef gearman_return_t rc
        servers = bytes(servers, 'utf8')
        rc = gearman_worker_add_servers(self._worker, servers)
        _raise_gearman_error(rc)

    def remove_servers(self):
        '''
        remove_servers(self)
        '''
        gearman_worker_remove_servers(self._worker)

    def set_identifier(self, identifier):
        '''
        set_identifier(self, identifier)
        sets the identifier that the server uses to identify the worker.
        '''
        cdef gearman_return_t rc
        identifier = bytes(identifier, 'utf8')
        rc = gearman_worker_set_identifier(self._worker,
                <const char *>identifier, len(identifier))
        _raise_gearman_error(rc)
        return True

    def work(self):
        '''
        work(self)
        '''
        cdef gearman_return_t rc
        rc = gearman_worker_work(self._worker)
        _raise_gearman_error(rc)
        return True

    def add_func(self, func_name, func, timeout = 0):
        '''
        add_func(self, func_name, func, timeout = 0)
        adds function with a callback
        it can be used to send messages to the client about the state of the work.
        '''
        cdef gearman_return_t rc
        if func_name in worker_callbacks.keys():
            raise DoubleWorkerError()
        worker_callbacks[func_name] = func
        func_name = bytes(func_name, 'utf8')
        rc = gearman_worker_define_function(self._worker, func_name,
                len(func_name), gearman_function_create(_func), timeout, NULL)
        _raise_gearman_error(rc)

cdef class Client:
    cdef gearman_client_st *_client

    def __cinit__(self):
        self._client = gearman_client_create(NULL)
        if self._client == NULL:
            raise RuntimeError('Memory allocation failure on client creation')

    def __dealloc__(self):
        gearman_client_free(self._client)

    # def set_timeout(self, timeout):
    #     gearman_client_set_timeout(self._client, timeout)

    def add_server(self, host, port):
        '''
        add_server(self, host, port)
        add an additional gearmand server to the list of servers that the client
        will take work from.
        '''
        cdef gearman_return_t rc
        host = bytes(host, 'utf8')
        rc = gearman_client_add_server(self._client, host, port)
        _raise_gearman_error(rc)

    def add_servers(self, servers):
        '''
        add_servers(self, servers)
        takes a list of gearmand servers that will be parsed to provide servers
        for the client. The format for this is SERVER[:PORT][,SERVER[:PORT]]...
        '''
        cdef gearman_return_t rc
        servers = bytes(servers, 'utf8')
        rc = gearman_client_add_servers(self._client, servers)
        _raise_gearman_error(rc)

    def remove_servers(self):
        '''
        remove_servers(self)
        '''
        gearman_client_remove_servers(self._client)

    def set_identifier(self, identifier):
        '''
        set_identifier(self, identifier)
        sets the identifier that the server uses to identify the client.
        '''
        cdef gearman_return_t rc
        identifier = bytes(identifier, 'utf8')
        rc = gearman_client_set_identifier(self._client,
                <const char *>identifier, len(identifier))
        _raise_gearman_error(rc)
        return True

    def do(self, func_name, workload, unique=None, background=False, level='normal'):
        '''
        do(self, func_name, workload, unique=None, background=False, level='normal')
        Executes a single request to the gearmand server
        if background is False waits for a reply else return the job_handle
        @level the request level
               only they set the gearman_priority_t to either high or low.
        '''
        cdef gearman_return_t ret
        cdef const char * result
        cdef size_t result_size
        cdef gearman_job_handle_t job_handle
        cdef const char *_unique
        if unique:
            unique = bytes(unique, 'utf8')
            _unique = <const char *> unique
        else:
            _unique = NULL
        func_name = bytes(func_name, 'utf8')
        if background:
            if level == 'low':
                ret = gearman_client_do_low_background(self._client, func_name,
                        _unique, <const char *>workload, len(workload),
                        job_handle)
            elif level == 'high':
                ret = gearman_client_do_high_background(self._client, func_name,
                        _unique, <const char *>workload, len(workload),
                        job_handle)
            else:
                ret = gearman_client_do_background(self._client, func_name,
                        _unique, <const char *>workload, len(workload),
                        job_handle)
            _raise_gearman_error(ret)
            return job_handle
        else:
            if level == 'low':
                result = <const char *>gearman_client_do_low(self._client,
                        func_name, _unique, <const char *>workload,
                        len(workload), &result_size, &ret)
            elif level == 'high':
                result = <const char *>gearman_client_do_high(self._client,
                        func_name, _unique, <const char *>workload,
                        len(workload), &result_size, &ret)
            else:
                result = <const char *>gearman_client_do(self._client,
                        func_name, _unique, <const char *>workload,
                        len(workload), &result_size, &ret)
            _raise_gearman_error(ret)
            return result

    def execute(self, func_name, workload, unique=None):
        cdef const char * _unique
        workload = bytes(workload, 'utf8')
        if unique:
            unique = bytes(unique, 'utf8')
            _unique = <const char *> unique
            len_unique = len(unique)
        else:
            _unique = NULL
            len_unique = 0

        func_name = bytes(func_name, 'utf8')

        task = Task()
        task._task = _gearman_execute(self._client, func_name, len(func_name),
                _unique, len_unique, <const char*> workload, len(workload))

        if task._task == NULL:
            raise GearmanError(gearman_client_error(self._client))

        return task

#     def add_task(self, func_name, workload, unique=None, background=False, level='normal'):
#         cdef gearman_return_t rc
#         cdef const char * _unique
#         workload = bytes(workload, 'utf8')
#         if unique:
#             unique = bytes(unique, 'utf8')
#             _unique = <const char *> unique
#             len_unique = len(unique)
#         else:
#             _unique = NULL
#             len_unique = 0
#
#         func_name = bytes(func_name, 'utf8')
#
#         task = Task()
#
#         if background:
#             if level == 'low':
#                 task._task = gearman_client_add_task_low_background(self._client, NULL, NULL,
#                         func_name, _unique,
#                         <const char *>workload, len(workload), &rc)
#
#             elif level == 'high':
#                 task._task = gearman_client_add_task_high_background(self._client, NULL, NULL,
#                         func_name, _unique,
#                         <const char *>workload, len(workload), &rc)
#
#             else:
#                 task._task = gearman_client_add_task(self._client, NULL, NULL,
#                         func_name, _unique,
#                         <const char *>workload, len(workload), &rc)
#         else:
#             if level == 'low':
#                 task._task = gearman_client_add_task_low(self._client, NULL, NULL,
#                         func_name, _unique,
#                         <const char *>workload, len(workload), &rc)
#
#             elif level == 'high':
#                 task._task = gearman_client_add_task_high(self._client, NULL, NULL,
#                         func_name, _unique,
#                         <const char *>workload, len(workload), &rc)
#
#             else:
#                 task._task = gearman_client_add_task(self._client, NULL, NULL,
#                         func_name, _unique,
#                         <const char *>workload, len(workload), &rc)
#
#         _raise_gearman_error(rc)
#
#         if task._task == NULL:
#             raise GearmanError(gearman_client_error(self._client))
#
#         return task
#
#     def run_tasks(self):
#         cdef gearman_return_t rc
#         rc = gearman_client_run_tasks(self._client)
#         _raise_gearman_error(rc)

cdef class Task:
    cdef gearman_task_st *_task

    @property
    def is_return(self):
        cdef gearman_return_t rc
        rc = gearman_task_return(self._task)
        if gearman_success(rc):
            return True
        else:
            return False

    @property
    def result(self):
        result = Result()
        result._result = gearman_task_result(self._task)
        return result

    @property
    def func_name(self):
        return str(gearman_task_function_name(self._task), 'utf8')

    @property
    def unique(self):
        return str(gearman_task_unique(self._task), 'utf8')

    @property
    def job_handle(self):
        return str(gearman_task_job_handle(self._task), 'utf8')

#     @property
#     def is_known(self):
#         return gearman_task_is_known(self._task)
#
#     @property
#     def is_running(self):
#         return gearman_task_is_running(self._task)
#
#     @property
#     def numerator(self):
#         return gearman_task_numerator(self._task)
#
#     @property
#     def denominator(self):
#         return gearman_task_denominator(self._task)
#
#     def give_workload(self, workload):
#         workload = bytes(workload, 'utf8')
#         gearman_task_give_workload(self._task, <const char *>workload, len(workload))
#
#     def send_workload(self, workload):
#         cdef gearman_return_t rc
#         workload = bytes(workload, 'utf8')
#         #ret = gearman_task_send_workload(self._task, <const char *>workload,
#         #        len(workload), &rc)
#         ret = gearman_task_send_workload(self._task, NULL,
#                 0, &rc)
#         _raise_gearman_error(rc)
#         return ret

cdef class Result:
    cdef gearman_result_st * _result

    @property
    def value(self):
        if self.size:
            return gearman_result_value(self._result)
        return b''

    @property
    def size(self):
        return gearman_result_size(self._result)
