import gleam/dynamic/decode
import gleam/int
import gleam/list
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import rsvp

type Model {
  Model(total: Int, cats: List(Cat))
}

type Cat {
  Cat(id: String, url: String)
}

type Msg {
  UserClickedAddCat
  UserClickedRemoveCat
  ApiReturnedCats(Result(List(Cat), rsvp.Error))
}

fn init(_args) -> #(Model, Effect(Msg)) {
  let model = Model(total: 0, cats: [])

  #(model, effect.none())
}

fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    UserClickedAddCat -> #(Model(..model, total: model.total + 1), get_cat())

    UserClickedRemoveCat -> #(
      Model(..model, total: model.total - 1, cats: list.drop(model.cats, 1)),
      effect.none(),
    )

    ApiReturnedCats(Ok(cats)) -> #(
      Model(..model, cats: list.append(model.cats, cats)),
      effect.none(),
    )

    // TODO: Do something with the Error
    // add error string to Model so we can surface it to the user
    ApiReturnedCats(Error(_)) -> #(model, effect.none())
  }
}

fn get_cat() -> Effect(Msg) {
  let decoder = {
    // TODO: rewrite this without using `use`, as a learning experiment
    use id <- decode.field("id", decode.string)
    use url <- decode.field("url", decode.string)

    decode.success(Cat(id:, url:))
  }
  let url = "https://api.thecatapi.com/v1/images/search"
  let handler = rsvp.expect_json(decode.list(decoder), ApiReturnedCats)

  rsvp.get(url, handler)
}

fn view(model: Model) -> Element(Msg) {
  html.div([], [
    html.div([], [
      html.button([event.on_click(UserClickedAddCat)], [html.text("Add cat")]),
      html.p([], [html.text(int.to_string(model.total))]),
      html.button([event.on_click(UserClickedRemoveCat)], [
        html.text("Remove cat"),
      ]),
    ]),
    html.div([], {
      list.map(model.cats, fn(cat) {
        html.img([
          attribute.src(cat.url),
          attribute.width(400),
          attribute.height(400),
        ])
      })
    }),
  ])
}

// entry point to the application
pub fn main() -> Nil {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}
