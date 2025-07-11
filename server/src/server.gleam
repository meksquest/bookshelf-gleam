import gleam/erlang/process
import mist
import server/router
import wisp
import wisp/wisp_mist

pub fn main() -> Nil {
  wisp.configure_logger()
  let secret_key_base = wisp.random_string(64)
  let assert Ok(_) =
    wisp_mist.handler(router.handle_request, secret_key_base)
    |> mist.new
    |> mist.start
  process.sleep_forever()
}
// To send a request and get a response
// `http localhost:4000`
//
//❯ http :4000/api/books
//❯ http :4000/api/books?title=The+Fifth+Season
//HTTP/1.1 200 OK
//connection: keep-alive
//content-length: 103
//content-type: application/json
//date: Fri, 11 Jul 2025 00:13:23 GMT
//
//{
//    "author": "N. K. Jemison",
//    "genre": "Science Fiction",
//    "status": "want_to_read",
//    "title": "The Fifth Season"
//}
