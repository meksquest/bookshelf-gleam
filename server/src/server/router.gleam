import gleam/http.{Get}
import gleam/json
import server/books.{type Book}
import server/web
import wisp.{type Request, type Response}

pub fn handle_request(req: Request) -> Response {
  use _req <- web.middleware(req)
  case wisp.path_segments(req) {
    ["api", "books"] -> books(req)
    _ -> wisp.not_found()
  }
}

fn books(req: Request) -> Response {
  case req.method {
    Get -> process_books_request(req)
    _ -> wisp.method_not_allowed([Get])
  }
}

fn process_books_request(req: Request) -> Response {
  case wisp.get_query(req) {
    [#("title", title)] -> get_book(title)
    _ -> list_books()
  }
}

fn get_book(title: String) -> Response {
  books.get_book(title)
  |> book_to_json
  |> json.to_string_tree
  |> wisp.json_response(200)
}

fn list_books() -> Response {
  books.list_books()
  |> json.array(fn(b) { book_to_json(b) })
  |> json.to_string_tree
  |> wisp.json_response(200)
}

fn book_to_json(book: Book) -> json.Json {
  json.object([
    #("author", json.string(book.author)),
    #("title", json.string(book.title)),
    #("genre", json.string(book.genre)),
    #("status", json.string(books.status_to_string(book.status))),
  ])
}
