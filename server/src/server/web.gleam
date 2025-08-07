import wisp

pub fn middleware(
  req: wisp.Request,
  handler_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  let req = wisp.method_override(req)
  use <- wisp.log_request(req)
  use <- wisp.rescue_crashes
  use req <- wisp.handle_head(req)

  handler_request(req)
  //|> wisp.set_header("access-control-allow-origin", "*")
}
