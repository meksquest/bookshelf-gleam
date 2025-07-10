import gleam/bytes_tree
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/json
import gleam/list
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

const books = [
  Book(
    author: "N. K. Jemison",
    title: "The Fifth Season",
    genre: "Science Fiction",
    status: WantToRead,
  ),
  Book(
    author: "Becky Chandler",
    title: "A Psalm to the Wild Built",
    genre: "Science Fiction",
    status: InProgress,
  ),
]

pub fn main() -> Nil {
  logging.configure()
  logging.set_level(logging.Debug)

  let internal_server_error =
    response.new(500)
    |> response.set_body(mist.Bytes(bytes_tree.new()))

  let not_found =
    response.new(404)
    |> response.set_body(mist.Bytes(bytes_tree.new()))

  let assert Ok(res) =
    fn(req: Request(Connection)) -> Response(ResponseData) {
      case request.path_segments(req) {
        ["api", "books"] ->
          case request.get_query(req) {
            Ok([#("title", title)]) ->
              get_book(title)
              |> book_to_json
              |> json.to_string
              |> success_response

            Ok(_) -> success_response(books_string())
            Error(_) -> internal_server_error
          }

        _ -> not_found
      }
    }
    |> mist.new
    |> mist.bind("localhost")
    |> mist.start

  echo res

  process.sleep_forever()
}

fn success_response(body: String) -> Response(ResponseData) {
  response.new(200)
  |> response.set_header("content-type", "application/json")
  |> response.set_body(mist.Bytes(bytes_tree.from_string(body)))
}

fn books_string() -> String {
  list_books()
  |> json.array(fn(b) { book_to_json(b) })
  |> json.to_string()
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

fn list_books() -> List(Book) {
  books
}

fn get_book(title: String) -> Book {
  let assert Ok(book) =
    list.find(list_books(), fn(book) { title == book.title })

  book
}
// Open the server Connection
// `gleam run`
// To send a request and get a response
// `http localhost:4000`
