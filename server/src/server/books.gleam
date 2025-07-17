import gleam/dict
import gleam/list
import gleam/option.{type Option}
import gleam/string
import gleam/time/calendar.{type Date}
import simplifile
import tom

pub fn status_to_string(status: Status) -> String {
  case status {
    WantToRead -> "want_to_read"
    InProgress -> "in_progress"
    Complete -> "complete"
    Unknown -> "unknown"
  }
}

pub fn string_to_status(string: String) -> Status {
  case string {
    "want_to_read" -> WantToRead
    "in_progress" -> InProgress
    "complete" -> Complete
    _ -> Unknown
  }
}

pub type Status {
  WantToRead
  InProgress
  Complete
  Unknown
}

pub type Book {
  Book(
    author: String,
    title: String,
    genre: String,
    status: Status,
    cover_art: Option(String),
    review: Option(List(String)),
    date_read: Option(Date),
  )
}

pub fn get_book(title: String) -> Book {
  let assert Ok(book) =
    list.find(list_books(), fn(book) { title == book.title })

  book
}

pub fn list_books() -> List(Book) {
  let assert Ok(input) = simplifile.read("priv/books.toml")
  let assert Ok(toml) = tom.parse(input)
  let assert Ok(tom.ArrayOfTables(books)) = dict.get(toml, "books")
  list.map(books, fn(x: dict.Dict(String, tom.Toml)) -> Book {
    let assert Ok(author) = tom.get_string(x, ["author"])
    let assert Ok(title) = tom.get_string(x, ["title"])
    let assert Ok(genre) = tom.get_string(x, ["genre"])
    let assert Ok(string_status) = tom.get_string(x, ["status"])
    let status = string_to_status(string_status)
    let cover_art = case tom.get_string(x, ["cover_art"]) {
      Ok(string_status) -> option.Some(string_status)
      _ -> option.None
    }
    let review = case tom.get_string(x, ["review"]) {
      Ok(string_review) ->
        string_review |> string.split("\n\n") |> option.Some()
      _ -> option.None
    }
    let date_read = case tom.get_date(x, ["date_read"]) {
      Ok(date_date_read) -> option.Some(date_date_read)
      _ -> option.None
    }

    // you can do this because it is in the same order as the type
    Book(author, title, genre, status, cover_art, review, date_read)
  })
}
