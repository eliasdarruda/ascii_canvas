# ASCII Canvas

This is a very simple application using **GenServer + SSE w/ HTTP2**

You can add different size ASCII rectangles in a canvas

Everything is persisted in memory in a GenServer that acts as a Process Manager and communicate with child-monitoring processes through a simple PubSub pattern

The server doesnt handle side-effects, this is handled by the client only if necessary

The server handles the canvas in memory lazily through Streams Operations, its only sended to the client the lines that was previously painted, this way the whole Matrix is processed only when needed

## Running

### Locally

`mix deps.get && iex -S mix`

### With Docker

`docker run --rm -p 4000:4000 -it $(docker build -q .)`

Running will:

- Start a HTTP Server that defaults to port 4000
- You can add rectangles in the canvas using the web interface
- Or you can add through `iex` running ```Ascii.Canvas.new_rect/6```
- To change canvas size dinamically though server use: `Ascii.Canvas.reset(width, height)`

## Possible improvements

- Persisting canvas in a AP database (like AntidoteDB) instead of in-memory
- Make a real front-end
- Add AsciiWeb tests
