![Heroku](http://heroku-badge.herokuapp.com/?app=nelson-approved&style=flat&svg=1)

# NelsonApproved

Nelson approved is a joke / practice-project to experiement with the development of web application in Elixir.

- Visit the WebApp: http://nelsonapproved.tk/

## Initial configuration

### Configuration files

You also need a Mashape API Key, that is used to accessed semantic analysis service.
Copy the following to a `secret.exs` file in the `config/` folder.

###### Secret.exs
```
use Mix.Config

config :nelson_approved,
  mashape_key: "YOUR_API_KEY"
```

Alternatively you can choose to not use the semantic analysis service altogether.
In that case, you can simply use the mock implementation of the network layer that is
provided at `NelsonApproved.AiNetworkMock`


###### Secret.exs | Without Semantic Analysis
```
use Mix.Config

config :nelson_approved,
  mashape_key: "Can be empty",
  network_ai_module: NelsonApproved.AiNetworkMock,
```

### Before first start

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
