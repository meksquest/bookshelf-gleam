import gleam/dict.{type Dict}
import gleam/erlang/process.{type Name, type Subject}
import gleam/list
import gleam/option.{type Option}
import gleam/otp/actor
import gleam/string
import gleam/time/calendar.{type Date}
import server/books.{type Book}
import simplifile
import tom.{type Toml}

pub type Message {
  GetBook(String)
  ListBooks(Subject(List(Book)))
  BooksActor
}

pub type State =
  List(Book)

pub fn start(name: Name(Message)) {
  let initial_state = get_initial_state()
  let assert Ok(actor) =
    actor.new(initial_state)
    |> actor.on_message(handle_message)
    |> actor.named(name)
    |> actor.start
  //let #(_, pid, _) = actor
  //process.register(pid, )
  echo actor
  actor
}

//pub fn send(message: Message) {Vjj
//
//}

pub fn handle_message(
  state: State,
  message: Message,
) -> actor.Next(State, Message) {
  case message {
    GetBook(title) -> get_book(title)
    ListBooks(client) -> {
      process.send(client, state)
      actor.continue(state)
    }
    _ -> actor.continue(state)
  }
}

fn get_book(title: String) -> actor.Next(State, Message) {
  todo
}

pub fn name() {
  process.new_name("BooksActor")
}

fn get_initial_state() -> List(Book) {
  let assert Ok(input) = simplifile.read("priv/books.toml")
  let assert Ok(toml) = tom.parse(input)
  let assert Ok(tom.ArrayOfTables(books)) = dict.get(toml, "books")
  list.map(books, fn(entry: dict.Dict(String, tom.Toml)) -> Book {
    // you can do this because it is in the same order as the type
    books.Book(
      parse_string(entry, "author"),
      parse_string(entry, "title"),
      parse_string(entry, "genre"),
      parse_string(entry, "status") |> books.string_to_status,
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
