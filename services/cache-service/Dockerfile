FROM python:3.13-slim

WORKDIR /app

RUN pip install pipenv

COPY Pipfile Pipfile.lock ./

RUN pipenv install --system --skip-lock

COPY app/ ./app/

EXPOSE 6379

CMD ["python", "app/main.py"]