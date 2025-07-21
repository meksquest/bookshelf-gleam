import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{type Option}
import gleam/string
import gleam/time/calendar.{type Date}
import simplifile
import tom.{type Toml}

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
  list.map(books, fn(entry: dict.Dict(String, tom.Toml)) -> Book {
    // you can do this because it is in the same order as the type
    Book(
      parse_string(entry, "author"),
      parse_string(entry, "title"),
      parse_string(entry, "genre"),
      parse_string(entry, "status") |> string_to_status,
      parse_optional_string(entry, "cover_art"),
      parse_optional_string_list(entry, "review"),
      parse_date(entry, "date_read"),
    )
  })
}

fn parse_string(entry: Dict(String, Toml), key: String) -> String {
  let assert Ok(entry) = tom.get_string(entry, [key])
  entry
}

fn parse_optional_string(
  entry: Dict(String, Toml),
  key: String,
) -> Option(String) {
  case tom.get_string(entry, [key]) {
    Ok(string_status) -> option.Some(string_status)
    _ -> option.None
  }
}

fn parse_optional_string_list(
  entry: Dict(String, Toml),
  key: String,
) -> Option(List(String)) {
  case tom.get_string(entry, [key]) {
    Ok(string_review) -> string_review |> string.split("\n\n") |> option.Some()
    _ -> option.None
  }
}

fn parse_date(entry: Dict(String, Toml), key: String) -> Option(Date) {
  case tom.get_date(entry, [key]) {
    Ok(date_date_read) -> option.Some(date_date_read)
    _ -> option.None
  }
}
