import gleam/http.{Get}
import gleam/int
import gleam/json.{type Json}
import gleam/option.{type Option}
import gleam/string
import gleam/time/calendar.{type Date}
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
  // eventually will want to move to a decoder
  // which is a special something in gleam, that takes data from the outside
  // world and turns it into Gleam data.
  // gleam.dynamic()
  json.object([
    #("author", json.string(book.author)),
    #("title", json.string(book.title)),
    #("genre", json.string(book.genre)),
    #("status", json.string(books.status_to_string(book.status))),
    #("cover_art", json.nullable(book.cover_art, json.string)),
    #("review", json_review(book.review)),
    #("date_read", json_date_read(book.date_read)),
  ])
}

fn json_review(review: Option(List(String))) -> Json {
  use lines <- json.nullable(review)
  use line <- json.array(lines)
  json.string(line)
}

fn json_date_read(date_read: Option(Date)) -> Json {
  json.nullable(date_read, fn(date: Date) -> Json {
    let day = date.day |> int.to_string
    let month =
      date.month
      |> calendar.month_to_int
      |> int.to_string
      |> string.pad_start(to: 2, with: "0")
    let year = date.year |> int.to_string
    json.string(string.concat([year, "-", month, "-", day]))
  })
}
