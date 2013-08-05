A python3 gearman client wraper on libgearman

    # client
    >>> import gearman
    >>> client = gearman.Client()
    >>> client.add_servers('localhost:4730')
    >>> client.do('echo', 'hello')

    # worker
    >>> import gearman
    >>> worker = gearman.Worker()
    >>> worker.add_servers('localhost:4730')
    >>> def echo(job):
    ...     print(job.workload)
    ...     job.complete(job.workload)
    >>> worker.add_func('echo', echo)
    >>> worker.work()
