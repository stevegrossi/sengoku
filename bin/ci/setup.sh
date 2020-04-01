# install asdf version manager
if ! asdf | grep version; then git clone https://github.com/HashNuke/asdf.git ~/.asdf; fi
echo '. $HOME/.asdf/asdf.sh' >> ~/.bashrc
source ~/.bashrc

# install erlang and elixir
asdf plugin-add erlang https://github.com/HashNuke/asdf-erlang.git
asdf plugin-add elixir https://github.com/HashNuke/asdf-elixir.git
erlang_version=$(awk '/erlang/ { print $2 }' .tool-versions) && asdf install erlang ${erlang_version}
elixir_version=$(awk '/elixir/ { print $2 }' .tool-versions) && asdf install elixir ${elixir_version}

# elixir dependencies
export MIX_ENV=test
mix local.hex --force
mix local.rebar --force
mix hex.info
mix deps.get
mix deps.compile
mix ecto.create

# Install phantomjs
export PHANTOMJS_VERSION="2.1.1"
export PHANTOMJS_HOST="https://s3.amazonaws.com/codeship-packages"
\curl -sSL https://raw.githubusercontent.com/codeship/scripts/master/packages/phantomjs.sh | bash -s

nvm use 6

# Assets: As of Phoenix 1.3, these live in assets/

# js dependencies
(cd assets/ && npm install)

# We need to build assets manually in the test environment.
# See: https://github.com/phoenixframework/phoenix/issues/2068
(cd assets/ && npm run deploy)
