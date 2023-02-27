open Runtime_events

(* This only works because we're not spawning and joining domains repeatedly! *)
let domain_heap_sizes = Array.make 100 0
let domain_heap_live = Array.make 100 0
let domain_heap_fragmentation = Array.make 100 0
let domain_heap_large_words = Array.make 100 0

let runtime_counter domain_id _ts counter counter_val =
  match counter with
  | EV_C_MAJOR_HEAP_POOL_WORDS ->
    Array.set domain_heap_sizes domain_id counter_val
  | EV_C_MAJOR_HEAP_POOL_LIVE_WORDS ->
    Array.set domain_heap_live domain_id counter_val
  | EV_C_MAJOR_HEAP_POOL_FRAG_WORDS ->
    Array.set domain_heap_fragmentation domain_id counter_val
  | EV_C_MAJOR_HEAP_LARGE_WORDS ->
    Array.set domain_heap_large_words domain_id counter_val
  | _ -> ()

let start () =
  let _ = Runtime_events.start () in
  let _ = Domain.spawn (fun () ->
    let cursor = create_cursor None in
    let callbacks = Callbacks.create ~runtime_counter () in
    while true do
      ignore(read_poll cursor callbacks None);
      let heap_pool_words_total = Array.fold_left (+) 0 domain_heap_sizes in
      let heap_pool_live_words_total = Array.fold_left (+) 0 domain_heap_live in
      let heap_pool_frag_words_total = Array.fold_left (+) 0 domain_heap_fragmentation in
      let heap_large_words = Array.fold_left (+) 0 domain_heap_large_words in
      let current_time = Unix.time () |> int_of_float in
      Printf.printf "heap\t%d\t%d\t%d\t%d\t%d\n%!" current_time heap_pool_words_total heap_pool_live_words_total heap_pool_frag_words_total heap_large_words;
      let pid = Unix.getpid () in
      let proc_rss = Unix.open_process_in ("cat /proc/" ^ (string_of_int pid ) ^ "/smaps_rollup | egrep 'Rss:' | awk '{print $2}'") in
      let read_proc_rss = (input_line proc_rss |> int_of_string) * 1000 in
      Printf.printf "mem\t%d\t%d\n%!" current_time read_proc_rss;
      Unix.sleepf 1.
    done
  ) in ()