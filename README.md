# Jolt

Need to quickly stand up a back-end JSON API for prototyping or educational purposes? Jolt gives you a full REST API with __zero coding__, powered by Elixir.

## Example

1. Create a `db.json` file with your example data:

    ```json
    {
      "products": [
        {
          "id": 1,
          "name": "Unicycle",
          "price": 99.0,
          "condition": "Excellent"
        }
      ],
      "todos": [
        {
          "id": 1,
          "title": "Shovel snow",
          "completed": true
        },
        {
          "id": 2,
          "phrase": "Rake leaves",
          "completed": false
        }
      ]
    }
    ```

2. Start Jolt:

    ```bash
    $ ./jolt db.json
    ```

3. Go to [http://localhost:4000/todos](), for example, and you'll get

    ```json
    [
      {
        "id": 1,
        "title": "Shovel snow",
        "completed": true
      },
      {
        "id": 2,
        "phrase": "Rake leaves",
        "completed": false
      }
    ]
    ```

Based on the previous `db.json` file, you also get the following routes:

```
GET    /products
GET    /products/1
POST   /products
PUT    /products/1
DELETE /products/1

GET    /todos
GET    /todos/1
POST   /todos
PUT    /todos/1
DELETE /todos/1

GET /db
```

If you make POST, PUT, or DELETE requests, changes are automatically saved to `db.json`.

## Installation

Jolt is intended to be used as a command-line tool. As such, you'll
need to run the following to create the `jolt` executable:

```bash
mix deps.get
mix escript.build
```

## Credits

Inspired by [json-server](https://github.com/typicode/json-server)

## License

MIT - [Mike Clark](https://github.com/clarkware)
