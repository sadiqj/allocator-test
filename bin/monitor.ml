open Runtime_events

let heap_pool_words_total = ref 0

let runtime_counter _domain_id _ts counter counter_val =
  match counter with
  | EV_C_MAJOR_HEAP_POOL_WORDS ->
    heap_pool_words_total := !heap_pool_words_total + counter_val
  | _ -> ()

let runtime_end _domain_id _ts phase =
  match phase with
  | EV_MAJOR_GC_CYCLE_DOMAINS ->
    begin
    Printf.printf "%d\n%!" !heap_pool_words_total;
    heap_pool_words_total := 0
    end
  | _ -> ()

let start () =
  let _ = Runtime_events.start () in
  let _ = Domain.spawn (fun () ->
    let cursor = create_cursor None in
    let callbacks = Callbacks.create ~runtime_counter ~runtime_end () in
    while true do
      ignore(read_poll cursor callbacks None);
      Unix.sleepf 1
    done
  ) in ()