uv
===

- Use `pyproject.toml` for project configuration
- Generate `uv.lock` for environment lock

| Description            | Command                      | Details                                                                  |
| -----------            | ---------------              | -------                                                                  |
| Install                | `brew install uv`            |                                                                          |
| Project init           | `uv init myproject`          |                                                                          |
| Environment setup      | `uv sync`                    | Creates `.venv` and `uv.lock`                                            |
| Environment lock       | `uv lock`                    |                                                                          |
| Environment activation | `source .venv/bin/activate`  |                                                                          |
| Django runserver       | `uv run manage.py runserver` | `uv sync` -> `source .venv/bin/activate` -> `python manage.py runserver` |
