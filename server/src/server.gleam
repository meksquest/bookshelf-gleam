import gleam/bytes_tree
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import logging
import mist.{type Connection, type ResponseData}

pub fn main() -> Nil {
  logging.configure()
  logging.set_level(logging.Debug)

  let assert Ok(res) =
    fn(_req: Request(Connection)) -> Response(ResponseData) {
      logging.log(logging.Info, "Boohiss")
      response.new(200)
      |> response.set_body(mist.Bytes(bytes_tree.from_string("Ghostty!!!!!!!")))
    }
    |> mist.new
    |> mist.bind("localhost")
    |> mist.start

  echo res

  process.sleep_forever()
}
// Open the server Connection
// `gleam run`
// To send a request and get a response
// `http localhost:4000`
