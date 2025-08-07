import gleam/dynamic/decode
import gleam/list
import lustre
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import rsvp

pub type Status {
  WantToRead
  InProgress
  Complete
  Unknown
}

pub type Book {
  Book(
    //author: String,
    title: String,
    //genre: String,
    //status: Status,
    //cover_art: Option(String),
    //review: Option(List(String)),
    //date_read: Option(Date),
  )
}

type Model {
  Model(books: List(Book))
}

type Msg {
  ApiReturnedBooks(Result(List(Book), rsvp.Error))
}

fn init(_args) -> #(Model, Effect(Msg)) {
  let model = Model(books: [])

  #(model, get_books())
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    ApiReturnedBooks(Ok(books)) -> #(Model(books: books), effect.none())

    // TODO: Do something with the Error
    // add error string to Model so we can surface it to the user
    ApiReturnedBooks(Error(_)) -> #(model, effect.none())
  }
}

fn get_books() -> Effect(Msg) {
  let decoder = {
    // TODO: rewrite this without using `use`, as a learning experiment
    use title <- decode.field("title", decode.string)

    decode.success(Book(title:))
  }
  let url = "http://localhost:4000/api/books"
  let handler = rsvp.expect_json(decode.list(decoder), ApiReturnedBooks)

  rsvp.get(url, handler)
}

fn view(model: Model) -> Element(Msg) {
  html.ul([], {
    list.map(model.books, fn(book) { html.li([], [html.text(book.title)]) })
  })
}

// entry point to the application
pub fn main() -> Nil {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}
