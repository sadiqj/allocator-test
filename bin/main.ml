let data_copies = 50
let outer_iterations = 1000
let inner_iterations = 10000

let get_test_data () =
  let data = ref [] in
  for _ = 0 to data_copies do
    data := (Yojson.Basic.from_file "data/test_data.json") :: !data
  done;
  data

let get_actor_ids data =
  let open Yojson.Basic.Util in
  List.map (fun json -> json |> convert_each (fun j -> j |> member "actor" |> member "id" |> to_int)) !data

let () =
  Monitor.start ();
  for i = 0 to outer_iterations do
    Printf.printf "Iteration %d\n%!" i;
    let actors = get_test_data () |> get_actor_ids |> List.flatten in
    for j = 1 to inner_iterations do
      let filtered_actors = List.filter (fun id -> id mod j == 0) actors in
         ignore(filtered_actors)
    done
  done