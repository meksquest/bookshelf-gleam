import gleam/erlang/process.{type Subject}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/otp/actor.{type StartError, type Started}
import server/books.{type Book}

// We want this type of module, but I'm currently having circular dependency
// and import issues, so the used version is currently in the books.gleam
// module
pub type State =
  List(Book)

pub type Message {
  ListBooks(Subject(List(Book)))
  GetBook(String, Subject(Option(Book)))
}

pub fn start() -> Result(Started(Subject(Message)), StartError) {
  let initial_state = books.load_books()
  // we know it is a builder, but we don't need know what it is, we just need to be
  // able pass it around
  let name = process.new_name("Repo")

  //actor.call(repo.data, 10, ListBooks) |> echo
  let assert Ok(repo) =
    actor.new(initial_state)
    |> actor.named(name)
    |> actor.on_message(handle_message)
    |> actor.start

  // repo.data is the subject
  actor.call(repo.data, 10, ListBooks) |> echo

  Ok(repo)
}

// an actor is a beam process, with a mailbox, it will receive and process
// messages
// this is the function that will get called when processes a Message
pub fn handle_message(
  state: State,
  message: Message,
) -> actor.Next(State, Message) {
  case message {
    // subject how one process can send info to another process (like pid in
    // elixir) it could be a bunch of different things
    // abstract way of sending info is called a subject, the Subject points to
    // a process
    ListBooks(subject) -> {
      actor.send(subject, state)
      actor.continue(state)
    }
    GetBook(title, subject) -> {
      let book = case list.find(state, fn(book) { title == book.title }) {
        Ok(book) -> Some(book)
        _ -> None
      }
      actor.send(subject, book)
      actor.continue(state)
    }
  }
}

pub fn list_books() {
  todo
  //let name = process.new_name("Repo")
  //
  //actor.call(name, 10, ListBooks)
}
