import io
import os

import uvicorn
from config import config
from fastapi import FastAPI
from prometheus_fastapi_instrumentator import Instrumentator
from routes.v1.main import router
from starlette.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

def read(*paths, **kwargs):
    """Read the contents of a text file safely.
    >>> read("VERSION")
    """
    content = ""
    with io.open(
        os.path.join(os.path.dirname(__file__), *paths),
        encoding=kwargs.get("encoding", "utf8"),
    ) as open_file:
        content = open_file.read().strip()
    return content

app = FastAPI(
    title="meeting-summarizer",
    description="Web app for summarizing meetings and conversations based on audio recordings",
    version=read("VERSION"),
    docs_url="/docs",
    redoc_url=None,
)
test

if config.server and config.server.get("cors_origins", None):
    app.add_middleware(
        CORSMiddleware,
        allow_origins=config.server.cors_origins,
        allow_credentials=config.get("server.cors_allow_credentials", True),
        allow_methods=config.get("server.cors_allow_methods", ["*"]),
        allow_headers=config.get("server.cors_allow_headers", ["*"]),
        expose_headers=[],
    )

app.include_router(router)
app.mount("/", StaticFiles(directory="app/static",html = True), name="static")
Instrumentator().instrument(app).expose(app, include_in_schema=False)


@app.on_event("startup")
async def database_connect():
    print(f"Starting meeting protocol service...")


@app.on_event("shutdown")
async def database_disconnect():
    print(f"Stopping meeting protocol service...")


if __name__ == "__main__":
    uvicorn.run(
        app, host=config.server.host, port=config.server.port, workers=1
    )


# @app.on_event("startup")
# def on_startup():
#     create_db_and_tables(engine)
