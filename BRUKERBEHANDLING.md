# Brukerbehandling for DailyTask

Dette dokumentet beskriver det implementerte brukerbehandlingssystemet for DailyTask-applikasjonen.

## Oversikt

Systemet inkluderer:
- Brukerregistrering med brukernavn og passord
- Innlogging og utlogging 
- Passord-hashing med bcrypt
- Session-håndtering med "husk meg"-funksjonalitet
- Authentication plugs for å beskytte ruter

## Installerte avhengigheter

I `mix.exs` er følgende avhengighet lagt til:
```elixir
{:bcrypt_elixir, "~> 3.0"}
```

## Database

### Migrasjon
Filen `priv/repo/migrations/001_create_users_table.exs` oppretter `users`-tabellen med:
- `id` (primærnøkkel)
- `username` (unik, ikke null)
- `hashed_password` (ikke null)
- `inserted_at` og `updated_at` tidsstempler

For å kjøre migrasjonen:
```bash
mix ecto.migrate
```

## Moduler og filer

### 1. User Schema (`lib/daily_task/accounts/user.ex`)
- Definerer User-skjemaet
- Validering av brukernavn (3-160 tegn, kun bokstaver/tall/underscore)
- Validering av passord (minimum 6 tegn)
- Automatisk passord-hashing med bcrypt
- `valid_password?/2` funksjon for autentisering

### 2. Accounts Context (`lib/daily_task/accounts.ex`)
- `get_user_by_username/1` - henter bruker basert på brukernavn
- `get_user_by_username_and_password/2` - autentiserer bruker
- `register_user/1` - registrerer ny bruker
- `change_user_registration/2` - changeset for forms

### 3. UserAuth Plug (`lib/daily_task_web/user_auth.ex`)
- `fetch_current_user/2` - henter nåværende bruker fra session
- `log_in_user/3` - logger inn bruker og setter session
- `log_out_user/1` - logger ut bruker
- `require_authenticated_user/2` - krever innlogget bruker
- `redirect_if_user_is_authenticated/2` - omdirigerer hvis allerede innlogget
- "Husk meg"-funksjonalitet med cookies

### 4. Kontrollere

#### UserSessionController (`lib/daily_task_web/controllers/user_session_controller.ex`)
- `new/2` - viser innloggingsskjema
- `create/2` - håndterer innlogging
- `delete/2` - håndterer utlogging

#### UserRegistrationController (`lib/daily_task_web/controllers/user_registration_controller.ex`)
- `new/2` - viser registreringsskjema  
- `create/2` - håndterer registrering

### 5. Views og Templates

#### HTML-moduler
- `lib/daily_task_web/controllers/user_session_html.ex`
- `lib/daily_task_web/controllers/user_registration_html.ex`

#### Templates
- `lib/daily_task_web/controllers/user_session_html/new.html.heex` - innloggingsskjema
- `lib/daily_task_web/controllers/user_registration_html/new.html.heex` - registreringsskjema

### 6. Router (`lib/daily_task_web/router.ex`)
Nye ruter:
- `GET /users/register` - registreringsskjema
- `POST /users/register` - registrer bruker
- `GET /users/log_in` - innloggingsskjema  
- `POST /users/log_in` - logg inn
- `DELETE /users/log_out` - logg ut

### 7. Layout (`lib/daily_task_web/components/layouts/app.html.heex`)
- Navigasjonsbar som viser:
  - "Logg inn" og "Registrer deg" lenker for ikke-innloggede brukere
  - Velkomstmelding og "Logg ut" lenke for innloggede brukere

## Bruk

### Oppstart
1. Installer avhengigheter: `mix deps.get`
2. Kjør migrasjon: `mix ecto.migrate`
3. Start server: `mix phx.server`

### Registrering
1. Gå til `/users/register`
2. Fyll inn brukernavn (3-160 tegn, kun bokstaver/tall/underscore)
3. Fyll inn passord (minimum 6 tegn)
4. Klikk "Opprett konto"

### Innlogging
1. Gå til `/users/log_in`
2. Fyll inn brukernavn og passord
3. Valgfritt: kryss av "Husk meg" for å holde deg innlogget
4. Klikk "Logg inn"

### Beskytte ruter
For å kreve innlogging på en rute, legg den til i scopet med `:require_authenticated_user` pipeline i routeren:

```elixir
scope "/", DailyTaskWeb do
  pipe_through [:browser, :require_authenticated_user]
  
  get "/beskyttet", MinController, :beskyttet_action
end
```

## Sikkerhet

- Passord hashes med bcrypt før lagring
- Session-tokens er sikre og roteres ved inn-/utlogging
- CSRF-beskyttelse aktivert
- Brukernavn-enumerering forhindres ved feil innlogging
- "Husk meg"-cookies er signerte og har utløpsdato

## Tilpasning

- Endre passordkrav i `User.validate_password/2`
- Endre brukernavnregler i `User.validate_username/2`  
- Tilpass omdirigering etter innlogging i `UserAuth.signed_in_path/1`
- Endre cookie-varighet i `@max_age` konstanten i `UserAuth`