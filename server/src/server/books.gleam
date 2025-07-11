import gleam/list

pub fn status_to_string(status: Status) -> String {
  case status {
    WantToRead -> "want_to_read"
    InProgress -> "in_progress"
    Complete -> "complete"
  }
}

pub type Status {
  WantToRead
  InProgress
  Complete
}

pub type Book {
  Book(author: String, title: String, genre: String, status: Status)
}

pub fn get_book(title: String) -> Book {
  let assert Ok(book) =
    list.find(list_books(), fn(book) { title == book.title })

  book
}

pub fn list_books() -> List(Book) {
  [
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
}
