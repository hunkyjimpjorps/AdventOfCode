-record(priority_queue, {
    queue :: utilities@prioqueue:p_queue({any(), utilities@prioqueue:ref()}),
    refs :: gleam@dict:dict(any(), utilities@prioqueue:ref())
}).
