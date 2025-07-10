import gleam/bytes_tree
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/json
import logging
import mist.{type Connection, type ResponseData}

type Status {
  WantToRead
  InProgress
  Complete
}

type Book {
  Book(author: String, title: String, genre: String, status: Status)
}

const the_fifth_season = Book(
  author: "N. K. Jemison",
  title: "The Fifth Season",
  genre: "Science Fiction",
  status: WantToRead,
)

pub fn main() -> Nil {
  logging.configure()
  logging.set_level(logging.Debug)

  let assert Ok(res) =
    fn(_req: Request(Connection)) -> Response(ResponseData) {
      let book =
        book_to_json(the_fifth_season)
        |> json.to_string()

      response.new(200)
      |> response.set_header("content-type", "application/json")
      |> response.set_body(mist.Bytes(bytes_tree.from_string(book)))
    }
    |> mist.new
    |> mist.bind("localhost")
    |> mist.start

  echo res

  process.sleep_forever()
}

fn book_to_json(book: Book) -> json.Json {
  json.object([
    #("author", json.string(book.author)),
    #("title", json.string(book.title)),
    #("genre", json.string(book.genre)),
    #("status", json.string(status_to_string(book.status))),
  ])
}

fn status_to_string(status: Status) -> String {
  case status {
    WantToRead -> "want_to_read"
    InProgress -> "in_progress"
    Complete -> "complete"
  }
}
// Open the server Connection
// `gleam run`
// To send a request and get a response
// `http localhost:4000`
