import sdl2, sdl2/gfx

discard sdl2.init(INIT_EVERYTHING)

var
  window: WindowPtr
  render: RendererPtr

window = createWindow("SDL Skeleton", 100, 100, 640,480, SDL_WINDOW_SHOWN)
render = createRenderer(window, -1, Renderer_Accelerated or Renderer_PresentVsync or Renderer_TargetTexture)

var
  event = sdl2.defaultEvent
  runGame = true
  fpsman: FpsManager

fpsman.init()
fpsman.setFrameRate(5)

proc getKeyValue(key: KeyboardEventPtr): cint =
  return key.keysym.sym

while runGame:
  echo("Running")
  while pollEvent(event):
    if event.kind == QuitEvent or (event.kind == KeyDown and getKeyValue(event.key) == K_Escape):
      runGame = false
      break

  let dt = fpsman.getFramerate() / 1000

  render.setDrawColor(0,80,0,255)
  render.clear()

  render.present()
  fpsman.delay()

destroy render
destroy window
