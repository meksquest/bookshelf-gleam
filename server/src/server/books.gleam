import gleam/list
import gleam/option.{type Option}
import gleam/time/calendar.{type Date}
import server

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
  server.list_books()
}
