FROM python:3.9 as build_image
COPY requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /wheels -r requirements.txt

FROM python:3.9
EXPOSE 8111
RUN mkdir -p /home/app
RUN groupadd app && useradd -g app app
ENV APP_HOME=/home/app
WORKDIR $APP_HOME

COPY --from=build_image /wheels /wheels
COPY --from=build_image requirements.txt .
RUN pip install --no-cache /wheels/*

COPY app/ $APP_HOME
RUN chown -R app:app $APP_HOME
USER app
CMD ["uvicorn", "app.main:app", "--host=0.0.0.0","--port=8111","--reload"]