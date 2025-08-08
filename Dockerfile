FROM public.ecr.aws/lambda/python:3.12

COPY poetry.lock pyproject.toml ./
COPY src ./src

RUN pip install --upgrade pip
RUN pip install poetry

RUN poetry config virtualenvs.create false
RUN poetry install --no-root

CMD ["src.main.handler"]